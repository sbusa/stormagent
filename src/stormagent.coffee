EventEmitter = require('events').EventEmitter
#
# base class for all stormstack agent components
#
class StormAgent extends EventEmitter

    validate = require('json-schema').validate
    fs = require 'fs'
    path = require 'path'
    extend = require('util')._extend
    async = require 'async'

    constructor: (config) ->

        # private helper functions
        util = require 'util'
        @log = (message, obj) ->
            out = "#{@constructor.name}: #{message}" if message?
            out += "\n" + util.inspect obj if obj?
            util.log out if out?

        @newdb = (filename,callback) ->
            dirty = require('dirty') "#{filename}" if filename?
            dirty._writeStream.on 'error', (err) =>
                @log err
                callback err if callback?
            dirty._writeStream.on 'open', =>
                @log 'dirty db initialized ok'
                callback null, dirty if callback?

        # setup default state variables
        uuid = require('node-uuid')
        @state =
            id: null
            instance: uuid.v4()
            activated: false
            running: false
            env: null

        @config ?= {}
        @functions ?= []

        # import self into self
        @import module

        @config = extend(@config, config) if config?
        @log "agent.config", @config
        @log "agent.functions", @functions

        @env = require './environment'

        ###
        @log "setting up directories..."
        fs=require('fs')
        try
            fs.mkdirSync("#{config.datadir}") unless fs.existsSync("#{config.datadir}")
            fs.mkdirSync("#{config.datadir}/db")  unless fs.existsSync("#{config.datadir}/db")
            fs.mkdirSync("#{config.datadir}/certs") unless fs.existsSync("#{config.datadir}/certs")
        catch error
            util.log "Error in creating data dirs"
        ###

        # handle when StormAgent webapp ready
        @on 'running', (@include) =>
            @state.running = true

    # public functions

    status: ->
        @state.config = @config
        @state.os = @env.os()
        @state

    # starts the agent web services API
    run: ->
        _agent = @;

        {@app} = require('zappajs') @config.port, ->
            @configure =>
                @use 'bodyParser', 'methodOverride', require("passport").initialize(), @app.router, 'static'
                @set 'basepath': '/v1.0'
                @set 'agent': _agent

            @configure
              development: => @use errorHandler: {dumpExceptions: on, showStack: on}
              production: => @use 'errorHandler'

            @enable 'serve jquery', 'minify'
            _agent.emit 'running', @include

    import: (id) ->
        if id instanceof Object and id.filename?
            self = true
            # let's find the module root dir
            id = p = id.filename
            while (p = path.dirname(p)) and p isnt path.sep and not fs.existsSync("#{p}/package.json")
                @log "checking #{p}..."
            id = p if p isnt path.sep

        # inspect if we are importing in other "storm" compatible modules
        try
            pkgconfig = require("#{id}/package.json").config
            storm = pkgconfig.storm
            @log "import - [#{id}] processing storm compatible module..."

            if storm.functions?
                @log "import - [#{id}] extending config and functions..."
                @config = extend( @config, pkgconfig) unless @state.running
                delete @config.storm # we don't need the storm property
                @log "import - [#{id}] available functions:", storm.functions
                @functions.push storm.functions... if storm.functions?

            if storm.plugins?
                @log "import - [#{id}] available plugins:", storm.plugins
                for plugfile in storm.plugins
                    plugin = require("#{id}/#{plugfile}")
                    continue unless plugin
                    @log "import - [#{id}] found valid plugin at #{plugfile}"
                    @include plugin if @state.running
                    # also schedule event trigger so that every time "running" is emitted, we re-load the APIs
                    @on 'running', (@include) =>
                        @log "loading storm-compatible plugin for: #{id}/#{plugfile}"
                        @include plugin
        catch err
            @log "import - [#{id}] is not a storm compatible module: "+err

        # return the real require call
        try
            require("#{id}") unless self? and self
        catch err
            @log "import - [#{id}] failed with: "+err

    execute: (command, callback) ->
        unless command
            return callback new Error "no valid command for execution!"

        console.log "executing #{command}..."
        exec = require('child_process').exec
        exec command, (error, stdout, stderr) =>
            if error
                callback error
            else
                callback()

    #
    # activation logic for connecting into stormstack bolt overlay network
    #
    activate: (storm, callback) ->
        request = require 'request'
        count = 0
        async.until(
            () => # test condition
                @state.activated? and @state.activated

            (repeat) => # repeat function
                count++
                @log "attempting activation (try #{count})..."
                async.waterfall [
                    # 1. discover environment if no storm.tracker
                    (next) =>
                        if storm? and storm.tracker? and storm.skey?
                            return next null, storm

                        @log "discovering environment..."
                        @env.discover (storm) =>
                            @state.env = storm
                            if storm? and storm.tracker? and storm.skey?
                                next null, storm
                            else
                                next new Error "unable to discover environment!"

                    # 2. lookup against stormtracker and retrieve agent ID if no storm.id
                    (storm, next) =>
                        if storm.id?
                            @state.id = storm.id
                            return next null, storm

                        @log "looking up agent ID from stormtracker... #{storm.tracker}"
                        request "#{storm.tracker}/skey/#{storm.skey}", (err, res, body) =>
                            try
                                next err if err
                                switch res.statusCode
                                    when 200
                                        agent = JSON.parse body
                                        @state.id = storm.id = agent.id
                                        next null, storm
                                    else next err
                            catch error
                                @log "unable to lookup: "+ error
                                next error

                    # 3. generate CSR request if no storm.bolt.cert
                    (storm, next) =>
                        storm.bolt ?= {}
                        if storm.bolt.cert? or (storm.csr? and storm.bolt.key?)
                            return next null, storm

                        @log "generating CSR..."
                        try
                            pem = require 'pem'
                            pem.createCSR
                                country: "US"
                                state: "CA"
                                locality: "El Segundo"
                                organization: "ClearPath Networks"
                                organizationUnit: "CPN"
                                commonName: storm.id
                                emailAddress: "#{storm.id}@intercloud.net"
                              , (err, res) =>
                                if res? and res.csr?
                                    @log "CSR generation completed:", res.csr
                                    storm.csr = res.csr
                                    storm.bolt.key = res.clientKey
                                    next null, storm
                                else
                                    new Error "CSR generation failure"
                        catch error
                            @log "unable to generate CSR request"
                            next error

                    # 4. get CSR signed by stormtracker if no storm.cert
                    (storm, next) =>
                        if storm.bolt.cert? and storm.bolt.key?
                            return next null,storm

                        @log "requesting CSR signing from #{storm.tracker}..."
                        r = request.post "#{storm.tracker}/#{storm.id}/csr", (err, res, body) =>
                            try
                                switch res.statusCode
                                    when 200
                                        # do something
                                        storm.bolt.cert = body
                                        next null, storm
                                    else next err
                            catch error
                                @log "unable to post CSR to get signed by stormtracker"
                                next error

                        form = r.form()
                        form.append 'file', storm.csr

                    # 5. retrieve bolt configuration if no storm.ca
                    (storm, next) =>
                        if storm.bolt.ca?
                            return next null,storm

                        @log "retrieving stormbolt configs from stormtracker..."
                        request "#{storm.tracker}/#{storm.id}/bolt", (err, res, body) =>
                            try
                                switch res.statusCode
                                    when 200
                                        bolt = JSON.parse body
                                        storm.bolt = extend(storm.bolt,bolt)
                                        next null, storm
                                    else next err
                            catch error
                                @log "unable to retrieve stormbolt configs"
                                next error

                ], (err, storm) => # finally
                    if storm?
                        @log "activation completed successfully"
                        @state.activated = true
                        @emit "activated", storm
                        repeat null, storm
                    else
                        @log "error during activation: #{err}"
                        setTimeout repeat, @config.repeatdelay

            (err, storm) => # final call
                @log "final call on until..."
                callback err, storm if callback?
        )

module.exports = StormAgent

# Garbage collect every 2 sec
# Run node with --expose-gc
if gc?
    setInterval (
        () -> gc()
    ), 2000


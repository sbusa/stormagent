EventEmitter = require('events').EventEmitter
#
# base class for all stormstack agent components
#
class StormAgent extends EventEmitter

    validate = require('json-schema').validate
    uuid = require('node-uuid')
    fs = require 'fs'
    path = require 'path'
    util = require 'util'
    extend = require('util')._extend
    async = require 'async'
    request = require 'request'

    constructor: (config) ->
        @log 'constructor called with:\n'+ @inspect config if config?

        # need to setup some basic defaults...
        @config = require('../package').config
        @config = extend(@config, config) if config?

        @config.repeatdelay ?= 5000
        @log "constructor initialized with:\n" + @inspect @config

        @log "setting up directories..."
        ###
        fs=require('fs')
        try
            fs.mkdirSync("#{config.datadir}") unless fs.existsSync("#{config.datadir}")
            fs.mkdirSync("#{config.datadir}/db")  unless fs.existsSync("#{config.datadir}/db")
            fs.mkdirSync("#{config.datadir}/certs") unless fs.existsSync("#{config.datadir}/certs")
        catch error
            util.log "Error in creating data dirs"
        ###

        @state =
            id: null
            instance: uuid.v4()
            activated: false
            running: false

        @functions = @config.functions

        # handle when StormAgent webapp ready
        @on 'ready', (zappa) =>
            zappa.app.agent = @
            @state.running = true
            @include = zappa.include

        @env = require './environment'

    # starts the agent web services API
    run: (callback) ->
        _agent = @;
        {@app} = require('zappajs') @config.port, ->
            @configure =>
              @use 'bodyParser', 'methodOverride', @app.router, 'static'
              @set 'basepath': '/v1.0'

            @configure
              development: => @use errorHandler: {dumpExceptions: on, showStack: on}
              production: => @use 'errorHandler'

            @enable 'serve jquery', 'minify'

            _agent.emit 'ready', this
            callback() if callback?


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

    log: (message) ->
        util.log "#{@constructor.name} - #{message}"

    inspect: util.inspect

    #
    # activation logic for connecting into stormstack bolt overlay network
    #
    activate: (storm, callback) ->
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
                            if storm? and storm.tracker? and storm.skey?
                                next null, storm
                            else
                                next new Error "unable to discover environment!"

                    # 2. lookup against stormtracker and retrieve agent ID if no storm.id
                    (storm, next) =>
                        if storm.id?
                            return next null, storm

                        @log "looking up agent ID from stormtracker... #{storm.tracker}"
                        request "#{storm.tracker}/skey/#{storm.skey}", (err, res, body) =>
                            try
                                next err if err
                                switch res.statusCode
                                    when 200
                                        agent = JSON.parse body
                                        storm.id = agent.id
                                        next null, storm
                                    else next err
                            catch error
                                @log "unable to lookup: "+ error
                                next error

                    # 3. generate CSR request if no storm.cert
                    (storm, next) =>
                        if storm.cert? and storm.key?
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
                                emailAddress: "#{agentId}@intercloud.net"
                              , (err, res) =>
                                if res? and res.csr?
                                    @log "Activation: openssl csr generation completed , result ",res.csr
                                    storm.csr = res.csr
                                    storm.key = res.clientkey
                                    next null, storm
                                else
                                    new Error "CSR generation failure"
                        catch error
                            @log "unable to generate CSR request"
                            next error

                    # 4. get CSR signed by stormtracker if no storm.cert
                    (storm, next) =>
                        if storm.cert? and storm.key?
                            return next null,storm

                        @log "requesting CSR signing from stormtracker..."
                        r = request.post "#{storm.tracker}/#{storm.id}/csr", (err, res, body) =>
                            try
                                switch res.statusCode
                                    when 200
                                        # do something
                                        storm.cert = body
                                        next null, storm
                                    else next err
                            catch error
                                @log "unable to post CSR to get signed by stormtracker"
                                next error

                        form = r.form()
                        form.append 'file', storm.csr

                    # 5. retrieve bolt configuration if no storm.bolt
                    (storm, next) =>
                        if storm.bolt?
                            return next null,storm

                        @log "retrieving stormbolt configs from stormtracker..."
                        request "#{storm.tracker}/#{storm.id}/bolt", (err, res, body) =>
                            try
                                switch res.statusCode
                                    when 200
                                        # do something
                                        storm.bolt = JSON.parse body
                                        next null, storm
                                    else next err
                            catch error
                                @log "unable to retrieve stormbolt configs"
                                next error

                ], (err, storm) => # finally
                    if storm?
                        @log "activation completed successfully"
                        @state.activated = true
                        @emit "active", storm
                        repeat
                    else
                        @log "error during activation: #{err}"
                        setTimeout repeat, @config.repeatdelay

            (err) => # final call
                @log "final call on until..."
                callback err, @state
        )

module.exports = StormAgent

# Garbage collect every 2 sec
# Run node with --expose-gc
if gc?
    setInterval (
        () -> gc()
    ), 2000

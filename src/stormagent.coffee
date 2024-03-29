EventEmitter = require('events').EventEmitter
#
# base class for all stormstack agent components
#

util = require 'util'
stormlog = (message, obj) ->
    out = "#{@constructor.name}: #{message}" if message?
    out += "\n" + util.inspect obj if obj?
    util.log out if out?

uuid = require('node-uuid')
class StormData extends EventEmitter

    validate = require('json-schema').validate

    constructor: (@id, @data, schema) ->
        @log = stormlog

        if schema?
            res = validate data, schema
            unless res.valid
                throw new Error "unable to validate passed in data during StormData creation! "+ util.inspect res

        @id ?= uuid.v4()
        @validity = data.validity if data?
        @saved = false

async = require 'async'
class StormRegistry extends EventEmitter

    constructor: (filename) ->
        @log = stormlog

        @running = true
        @entries = {}

        if filename
            @db = require('dirty') "#{filename}"
            @db.on 'load', =>
                @log "loaded #{filename}"
                try
                    @db.forEach (key,val) =>
                        @log "found #{key} with:", val
                        @emit 'load', key, val if val?
                catch err
                    @log "issue during processing the db file at #{filename}"
                @emit 'ready'
            @db._writeStream.on 'error', (err) =>
                @log err
        else
            @emit 'ready'

    add: (key, entry) ->
        return unless entry?
        @remove key if @get key

        key ?= uuid.v4() # if no key provided, dynamically generate one
        entry.id ?= key
        entry.saved ?= false
        @log "adding #{key} into entries"
        if @db? and not entry.saved
            data = entry
            data = entry.data if entry instanceof StormData
            @db.set key, data
            entry.saved = true
        @entries[key] = entry
        @emit 'added', entry
        entry

    get: (key) ->
        return unless key?
        @entries[key]

    remove: (key) ->
        return unless key?
        @log "removing #{key} from entries"
        entry = @entries[key]
        # delete the key from obj first...
        delete @entries[key]
        @emit 'removed', entry if entry?
        # check if data-backend and there is an entry that's been saved
        if @db? and entry? and entry.saved
            @db.rm key

    update: (key, entry) ->
        return unless key? and entry?
        if @db? and not entry.saved
            data = entry
            data = entry.data if entry instanceof StormData
            @db.set key, data
            entry.saved = true
        @entries[key] = entry
        @emit 'updated', entry
        entry

    list: ->
        @get key for key of @entries

    checksum: ->
        crypto = require 'crypto' # for checksum capability on registry
        md5 = crypto.createHash "md5"
        md5.update key for key,entry of @entries
        md5.digest "hex"

    expires: (interval,validity) ->
        # initialize validity if not already set
        validity ?= 60 * 60
        for key,entry of @entries
             do (entry) -> entry.validity ?= validity

        async.whilst(
            () => # test condition
                @running
            (repeat) =>
                for key,entry of @entries
                    unless entry?
                        @remove key
                        continue
                    do (key,entry) =>
                        #@log "DEBUG: #{key} has validity=#{entry.validity}"
                        @entries[key].validity -= interval / 1000
                        unless @entries[key].validity > 1
                            @remove key
                            @emit "expired", entry
                setTimeout(repeat, interval)
            (err) =>
                @log "stormregistry stopped, validity checker stopping..."
        )

class StormAgent extends EventEmitter

    validate = require('json-schema').validate
    fs = require 'fs'
    path = require 'path'
    extend = require('util')._extend

    constructor: (config) ->

        # private helper functions
        @log = stormlog
        @newdb = (filename,callback) ->

        @timestamp = ->
            d = new Date()
            pad = (n) ->
                sn = n.toString(10)
                sn = '0' + sn if n < 10
                sn
            time = [pad(d.getHours()),pad(d.getMinutes()),pad(d.getSeconds())].join(':')
            months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
            [d.getDate(), months[d.getMonth()], time].join(' ')

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

        # process environmental variables
        for key,val of process.env
            match = "#{key}".match /^npm_package_config_(.*)$/
            if match?
                @log "found npm package config #{match} = #{val}"

        @config = extend @config, config if config?
        @log "agent.config", @config
        @log "agent.functions", @functions

        @env = require './environment'

        ###
        @log "setting up directories..."
        try
            fs.mkdirSync("#{config.datadir}") unless fs.existsSync("#{config.datadir}")
            fs.mkdirSync("#{config.datadir}/db")  unless fs.existsSync("#{config.datadir}/db")
            fs.mkdirSync("#{config.datadir}/certs") unless fs.existsSync("#{config.datadir}/certs")
        catch error
            util.log "Error in creating data dirs"
        ###

        # handle when StormAgent webapp ready
        @on 'running', (@include) =>
            console.log "we are running now..."
            @state.running = true

    # public functions
    status: ->
        @state.config = extend {},@config
        delete @state.config.ca
        delete @state.config.cert
        delete @state.config.key
        if @state.env? and @state.env.bolt?
            delete @state.env.bolt.ca
            delete @state.env.bolt.cert
            delete @state.env.bolt.key
        @state.os = @env.os()
        @state

    validate: (input,schema) ->
        if schema?
            res = validate input, schema
            res.valid
        else
            true

    # starts the agent web services API
    run: (config, schema) ->
        _agent = @;

        if config?
            if schema?
                res = validate config, schema
                @log 'run - validation of runtime config:', res
                @config = extend @config, config if res.valid
            else
                @config = extend @config, config

        if @config.logfile?
            @log "redirecting console.log to #{@config.logfile}..."
            try
                logfile=fs.createWriteStream @config.logfile, { flags: 'a' }
                logfile.on 'open', =>
                    @log "starting stdout/stderr redirection..."
                    process.__defineGetter__ "stdout", -> logfile
                    process.__defineGetter__ "stderr", -> logfile
                    @log 'running with: ', @config
                logfile.on 'error', (err) =>
                    @log "unable to redirect stdout due to:", err
            catch err
                @log "unable to redirect stdout due to:", err

        {@app} = require('zappajs') @config.port, ->
            morgan = require('morgan')
            morgan.token 'date', _agent.timestamp
            logger = morgan(":date - :method :url :status :response-time ms - :remote-addr")

            @configure =>
                @use 'bodyParser', 'methodOverride', logger, require("passport").initialize(), @app.router, 'static'
                @set 'basepath': '/v1.0'
                @set 'agent': _agent

            @configure
              development: => @use errorHandler: {dumpExceptions: on, showStack: on}
              production: => @use 'errorHandler'

            _agent.emit 'running', @include

    import: (id) ->
        #@log "import - id:", id
        if id instanceof Object and id.filename?
            self = true
            # let's find the module root dir
            id = p = id.filename
            while (p = path.dirname(p)) and p isnt path.sep and not fs.existsSync("#{p}/package.json")
                @log "checking #{p}..."
            id = p if p isnt path.sep

        # inspect if we are importing in other "storm" compatible modules
        try
            (@state)[b = require("#{id}/package.json").name ?= id] = require("#{id}/package.json").version
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
                    do (plugfile) =>
                        plugin = require("#{id}/#{plugfile}")
                        return unless plugin

                        @log "import - [#{id}] found valid plugin at #{plugfile}"
                        @include plugin if @state.running
                        # also schedule event trigger so that every time "running" is emitted, we re-load the APIs
                        @on 'running', (@include) =>
                            @log "loading storm-compatible plugin for: #{id}/#{plugfile}"
                            try
                                @include plugin
                            catch err
                                @log "Unable to include the plugin #{plugin}!! #{err}"
        catch err
            @log "import - [#{id}] is not a storm compatible module: "+err

        # return the real require call
        try
            require("#{id}") unless self? and self
        catch err
            @log "import - [#{id}] failed with: "+err

    imports: (modules...) ->
        @import module for module in modules

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

        # simple helper wrapper to issue a call with STORM authorization header
        srequest = (method, url, storm, callback) ->
            method(
                url: url
                timeout: 2000
              , (err, res, body) ->
                callback err, res, body if callback?
            ).auth storm.skey, storm.token if method? and method instanceof Function and url? and storm?

        async.until(
            () => # test condition
                @state.activated

            (repeat) => # repeat function
                count++
                @log "attempting activation (try #{count})..."
                async.waterfall [
                    # 1. discover environment if no storm.tracker
                    (next) =>
                        if storm? and storm.tracker? and storm.skey? and storm.token?
                            return next null, storm

                        @log "discovering environment..."
                        @env.discover (storm) =>
                            if storm? and storm.provider? and storm.skey?
                                @log "detected provider as: #{storm.provider} with skey: #{storm.skey}"
                                if storm.tracker? and storm.token?
                                    @state.env = storm
                                    next null, storm
                                else
                                    next new Error "unable to retrieve storm tracker and token data!"
                            else
                                next new Error "unable to discover environment!"

                    # 2. lookup against stormtracker and retrieve agent ID if no storm.id
                    (storm, next) =>
                        if storm.id?
                            @state.id = storm.id
                            return next null, storm

                        @log "looking up agent ID from stormtracker... #{storm.tracker}"
                        srequest request, "#{storm.tracker}/agents/serialkey/#{storm.skey}", storm, (err, res, body) =>
                            try
                                next err if err
                                switch res.statusCode
                                    when 200
                                        agent = JSON.parse body
                                        @state.id = storm.id = agent.id
                                        next null, storm
                                    else
                                        next new Error "received #{res.statusCode} from stormtracker"
                            catch error
                                @log "unable to lookup agent ID: "+ error
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
                                    storm.bolt.key = new Buffer storm.bolt.key unless storm.bolt.key instanceof Buffer
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
                        r = srequest request.post, "#{storm.tracker}/agents/#{storm.id}/csr", storm, (err, res, body) =>
                            try
                                next err if err
                                switch res.statusCode
                                    when 200
                                        # do something
                                        try
                                            cert = JSON.parse body
                                            if cert.data? and cert.encoding?
                                                @log "decoding signed cert data with #{body.encoding}"
                                                storm.bolt.cert = new Buffer cert.data, cert.encoding
                                            else
                                                @log "unkown format for cert... leaving cert AS-IS"
                                                storm.bolt.cert = body
                                        catch err
                                            @log "provided cert is not JSON... treating as string"
                                            storm.bolt.cert = new Buffer body

                                        next null, storm
                                    else
                                        next new Error "received #{res.statusCode} from stormtracker"
                            catch error
                                @log "unable to post CSR to get signed by stormtracker", error
                                next error

                        form = r.form()
                        form.append 'file', storm.csr

                    # 5. retrieve bolt configuration if no storm.ca
                    (storm, next) =>
                        if storm.bolt.ca?
                            return next null,storm

                        srequest request, "#{storm.tracker}/agents/#{storm.id}/bolt", storm, (err, res, body) =>
                            try
                                next err if err
                                switch res.statusCode
                                    when 200
                                        bolt = JSON.parse body
                                        @log "retrieving stormbolt configs from stormtracker...",bolt
                                        throw new Error "missing bolt.ca!" unless bolt.ca?
                                        if bolt.ca.data? and bolt.ca.encoding?
                                            @log "decoding signed cert data with #{bolt.ca.encoding}"
                                            bolt.ca = new Buffer bolt.ca.data, bolt.ca.encoding
                                        storm.bolt = extend(storm.bolt, bolt)
                                        next null, storm
                                    else
                                        next new Error "received #{res.statusCode} from stormtracker"
                            catch error
                                @log "unable to retrieve stormbolt configs"
                                next error

                ], (err, storm) => # finally
                    if err or not storm
                        @log "error during activation:", err
                        setTimeout repeat, @config.repeatdelay
                    else
                        try
                            # writing the certs in to file
                            fs.mkdirSync("/etc/identity") unless fs.existsSync("/etc/identity")
                            fs.writeFileSync('/etc/identity/minion.key',storm.bolt.key)
                            fs.writeFileSync('/etc/identity/minion.crt',storm.bolt.cert)
                            fs.writeFileSync('/etc/identity/ca.crt',storm.bolt.ca)
                        catch err
                            @log "Error writing the certs in to file" + err
                        
                        @log "activation completed successfully"
                        @state.activated = true
                        @emit "activated", storm
                        repeat storm

            (storm) => # final call
                @log "final call on until...",storm
                unless storm instanceof Error
                    callback storm if callback?
        )

module.exports = StormAgent
module.exports.StormData = StormData
module.exports.StormRegistry = StormRegistry

#-------------------------------------------------------------------------------------------

if require.main is module
    argv = require('minimist')(process.argv.slice(2))
    if argv.h?
        console.log """
            -h view this help
            -p port number
            -l logfile
            -d datadir
        """
        return

    config = {}
    config.port    = argv.p ? 5000
    config.logfile = argv.l ? "/var/log/stormagent.log"
    config.datadir = argv.d ? "/var/stormstack"

    storm = null # override during dev

    agent = new StormAgent config
    #
    # activation and establishment of bolt channel is *optionally* handled at the application layer
    #
    agent.on "running", ->
        @log "unit testing..."
        @log "#1 - agent.env.discover", @env.discover()
        @log "#2 - agent.env.os", @env.os()
        @log "#3 - agent.activate"
        @activate storm, (err, status) =>
            @log "activation completed with", status

    agent.on "activated", (storm) ->
        @log "activated with:", storm

    agent.run()

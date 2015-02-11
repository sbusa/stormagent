os = require('os')

class Environment

    async = require 'async'
    request = require 'request'
    util = require 'util'

    # TODO - must support virtual software instance as well as CPE hardware instance!

    providers = [
        name: "openstack"
        metaurl: "http://169.254.169.254/openstack/latest/meta_data.json"
       , # this comma MUST be one column lower
        name: "gce"
        metaurl: "http://169.254.169.254/computeMetadata/v1"
       , # below provider is minitracker details.. to be removed
        name: "unit-test"
        metaurl:"http://192.168.122.248/latest/meta-data"
    ]


    constructor: ->
        console.log 'Environment constructor called'

    check: (provider, callback) ->

        # here, we actually should handle case where metadata can be read from json file - /etc/meta-data.json
        metadata = require('/etc/meta-data')
        util.log "reading from file..."
        
        if metadata?
            url = require('url').parse metadata.meta.stormtracker
            auth = url.auth
            delete url.auth

            stormdata =
                provider: provider.name
                skey:     metadata.uuid
                tracker:  require('url').format url
                token:    auth

            console.log "Building Stormdata from json file..."
            return callback stormdata if stormdata.skey

        # here, we actually should handle case where provider.metaurl is NOT set

        return callback() unless provider? and provider.metaurl?

        error = false
        util.log "making a request to #{provider.metaurl}..."
        request
            url: provider.metaurl
            timeout: 2000
          , (err, res, body) ->
            if err
                util.log "request failed: "+err
                unless error
                    error = true
                    return callback()

            try
                util.log "#{provider.name} metadata http response statusCode: " + res.statusCode
                if res.statusCode == 200
                    metadata = JSON.parse body
                    util.log "metadata: "+metadata

                    url = require('url').parse metadata.meta.stormtracker
                    auth = url.auth
                    delete url.auth

                    stormdata =
                        provider: provider.name
                        skey:     metadata.uuid
                        tracker:  require('url').format url
                        token:    auth

                    return callback stormdata if stormdata.skey
            catch error
                util.log "check failed for #{provider.name}: " + error

            callback()

    discover: (callback) ->
        i = 0
        stormdata = null
        async.until(
            () -> # test condition
                i >= providers.length or stormdata?

            (repeat) => # repeat function
                @check providers[i++], (match) ->
                    stormdata = match if match?
                    setTimeout repeat, 1000

            (err) -> # finally
                if err or not stormdata?
                    util.log "unable to discover the running provider environment!"
                callback stormdata if callback?
        )

    os: ->
        tmpdir: os.tmpdir()
        endianness: os.endianness()
        hostname: os.hostname()
        type: os.type()
        platform: os.platform()
        release: os.release()
        arch: os.arch()
        uptime: os.uptime()
        loadavg: os.loadavg()
        totalmem: os.totalmem()
        freemem: os.freemem()
        cpus: os.cpus()
        networkInterfaces: os.networkInterfaces()

module.exports = new Environment


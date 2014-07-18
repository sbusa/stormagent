# stormagent API endpoints

include = ->

    validate = require('json-schema').validate
    schema = {}
    console.log " what we got", agent, @agent
    agent = @agent

    @server.get  '/status', (req, res, next)  ->
        res.send agent.status()
        next()

# /environment

    @server.get '/environment', (req, res, next)  ->
        resp = agent.env.os()
        console.log res
        send resp
        next()

# /personality
    schema.personality =
        name: "personality"
        type: "object"
        items:
            type: "object"
            additionalProperties: false
            properties:
                path:     { type: "string", required: true }
                contents: { type: "string", required: true }
                postxfer: { type: "string" }

    @server.post '/personality', (req, res, next)  ->
        console.log 'performing schema validation on incoming service JSON'

        #console.log @body

        result = validate req.body, schema.personality
        console.log result
        return next new Error "Invalid personality posting!: #{result.errors}" unless result.valid

        fs = require 'fs'
        exec = require('child_process').exec
        path = require 'path'

        for p in req.body.personality
            #console.log p
            do (p) ->
                console.log "writing personality to #{p.path}..."
                # debug /tmp
                # p.path = '/tmp'+p.path
                dir = path.dirname p.path
                unless path.existsSync dir
                    exec "mkdir -p #{dir}", (error, stdout, stderr) =>
                        unless error
                            fs.writeFile p.path, new Buffer(p.contents || '',"base64"), ->
                                # this feature currently disabled DO NOT re-enable!
                                if p.postxfer?
                                    exec "#{p.postxfer}", (error, stdout, stderr) ->
                                        console.log "issuing '#{p.postxfer}'... stderr: #{stderr}" if error
                                        console.log "issuing '#{p.postxfer}'... stdout: #{stdout}" unless error
                else
                    fs.writeFile p.path, new Buffer(p.contents || '',"base64"), ->
                        # this feature currently disabled DO NOT re-enable!
                        if p.postxfer?
                            exec "#{p.postxfer}", (error, stdout, stderr) ->
                                console.log "issuing '#{p.postxfer}'... stderr: #{stderr}" if error
                                console.log "issuing '#{p.postxfer}'... stdout: #{stdout}" unless error

        res.send { result: 'success' }
        next()

module.exports.include = include

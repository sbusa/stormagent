# stormagent API endpoints

@include = ->

    validate = require('json-schema').validate
    schema = {}
    agent = @settings.agent

    @get '/status': ->
        @send agent.status()

# /environment

    @get '/environment': ->
        res = agent.env.os()
        console.log res
        @send res

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

    @post '/personality': ->
        console.log 'performing schema validation on incoming service JSON'

        #console.log @body

        result = validate @body, schema.personality
        console.log result
        return @next new Error "Invalid personality posting!: #{result.errors}" unless result.valid

        fs = require 'fs'
        exec = require('child_process').exec
        path = require 'path'

        for p in @body.personality
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

        @send { result: 'success' }


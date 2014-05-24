# process environmental variables

#util = require 'util'

#util.log util.inspect process

for key,val of process.env
    console.log "#{key} = #{val}"
    match = "#{key}".match /^npm_package_config_(.*)$/
    if match?
        console.log "found npm package config #{match} = #{val}"

#nconf = require 'nconf'
#nconf.use('memory').argv().env()

#console.log nconf.get 'npm:package:config:port'

return


# COMMENT OUT below "storm" object FOR REAL USE
# test storm data for manual config
# storm = null <-- should be the default
storm =
    provider: null
    tracker: null
    skey: null
    id: null
    bolt:
        cert: ""
        key: ""
        ca: ""
        uplinks: [ "bolt://stormtower.dev.intercloud.net" ]
        uplinkStrategy: "round-robin"
        allowRelay: true
        relayPort: 8017
        allowedPorts: [ 5000 ]
        listenPort: 443
        beaconInterval: 10
        beaconRetry: 3



# start the stormagent instance
StormAgent = require './stormagent'
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


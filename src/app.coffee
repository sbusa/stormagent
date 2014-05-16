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
agent.on "zappa.ready", ->
    @log "unit testing..."
    @log "#1 - agent.env.discover\n" + @env.discover()
    @log "#2 - agent.env.os\n" + @inspect @env.os()
    @log "#3 - agent.activate"
    @activate storm, (err, status) =>
        @log "activation completed with:\n" + @inspect status

agent.on "activated", (storm) ->
    @log "activated with:\n" + @inspect storm

agent.run()

# Garbage collect every 2 sec
# Run node with --expose-gc
if gc?
    setInterval (
        () -> gc()
    ), 2000

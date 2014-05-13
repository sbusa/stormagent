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
config.datadir = argv.d ? "/var/stormagent"

# test storm data for manual config
storm =
    provider: "openstack"
    tracker: "https://allow@stormtracker.dev.intercloud.net"
    skey: "some-secure-serial-key"
    id: "testing-uuid"
    cert: ""
    key: ""
    bolt:
        remote: "bolt://bolt.dev.intercloud.net"
        listen: 443
        local: 8017
        local_forwarding_ports: [ 5000 ]
        beacon:
            interval: 10
            retry: 3

# start the stormagent instance
StormAgent = require './stormagent'
agent = new StormAgent config
agent.on "ready", ->
    @log "starting activation..."
    @activate storm, (err, status) =>
        @log "activation completed with:\n", @inspect status

agent.on "active", (storm) ->
    @log "firing up stormbolt..."
    # stormbolt = require 'stormbolt'
    # bolt = new stormbolt storm
    # bolt.on "error", (err) =>
    #     @log "bolt error, force agent re-activation..."
    #     @activate config.storm, (err, status) =>
    #         @log "re-activation completed with #{status}"
    #bolt.start()

agent.run()


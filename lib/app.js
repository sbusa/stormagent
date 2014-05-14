// Generated by CoffeeScript 1.7.1
(function() {
  var StormAgent, agent, argv, config, storm, _ref, _ref1, _ref2;

  argv = require('minimist')(process.argv.slice(2));

  if (argv.h != null) {
    console.log("-h view this help\n-p port number\n-l logfile\n-d datadir");
    return;
  }

  config = {};

  config.port = (_ref = argv.p) != null ? _ref : 5000;

  config.logfile = (_ref1 = argv.l) != null ? _ref1 : "/var/log/stormagent.log";

  config.datadir = (_ref2 = argv.d) != null ? _ref2 : "/var/stormagent";

  storm = {
    provider: "openstack",
    tracker: "https://allow@stormtracker.dev.intercloud.net",
    skey: "some-secure-serial-key",
    id: "testing-uuid",
    cert: "",
    key: "",
    bolt: {
      remote: "bolt://bolt.dev.intercloud.net",
      listen: 443,
      local: 8017,
      local_forwarding_ports: [5000],
      beacon: {
        interval: 10,
        retry: 3
      }
    }
  };

  StormAgent = require('./stormagent');

  agent = new StormAgent(config);

  agent.on("ready", function() {
    this.log("starting activation...");
    return this.activate(storm, (function(_this) {
      return function(err, status) {
        return _this.log("activation completed with:\n", _this.inspect(status));
      };
    })(this));
  });

  agent.on("active", function(storm) {
    return this.log("firing up stormbolt...");
  });

  agent.run();

}).call(this);
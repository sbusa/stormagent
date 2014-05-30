(function() {
  var StormAgent, agent, key, match, storm, val, _ref;

  _ref = process.env;
  for (key in _ref) {
    val = _ref[key];
    console.log("" + key + " = " + val);
    match = ("" + key).match(/^npm_package_config_(.*)$/);
    if (match != null) {
      console.log("found npm package config " + match + " = " + val);
    }
  }

  return;

  storm = {
    provider: null,
    tracker: null,
    skey: null,
    id: null,
    bolt: {
      cert: "",
      key: "",
      ca: "",
      uplinks: ["bolt://stormtower.dev.intercloud.net"],
      uplinkStrategy: "round-robin",
      allowRelay: true,
      relayPort: 8017,
      allowedPorts: [5000],
      listenPort: 443,
      beaconInterval: 10,
      beaconRetry: 3
    }
  };

  StormAgent = require('./stormagent');

  agent = new StormAgent(config);

  agent.on("running", function() {
    var _this = this;
    this.log("unit testing...");
    this.log("#1 - agent.env.discover", this.env.discover());
    this.log("#2 - agent.env.os", this.env.os());
    this.log("#3 - agent.activate");
    return this.activate(storm, function(err, status) {
      return _this.log("activation completed with", status);
    });
  });

  agent.on("activated", function(storm) {
    return this.log("activated with:", storm);
  });

  agent.run();

}).call(this);

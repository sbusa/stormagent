(function() {
  var Environment, os;

  os = require('os');

  Environment = (function() {
    var async, providers, request, util;

    async = require('async');

    request = require('request');

    util = require('util');

    providers = [
      {
        name: "openstack",
        metaurl: "http://169.254.169.254/openstack/latest/meta_data.json"
      }, {
        name: "gce",
        metaurl: "http://169.254.169.254/computeMetadata/v1"
      }, {
        name: "unit-test",
        metaurl: "http://192.168.122.248/latest/meta-data"
      }
    ];

    function Environment() {
      console.log('Environment constructor called');
    }

    Environment.prototype.check = function(provider, callback) {
      var error;
      if (!((provider != null) && (provider.metaurl != null))) return callback();
      error = false;
      util.log("making a request to " + provider.metaurl + "...");
      return request({
        url: provider.metaurl,
        timeout: 2000
      }, function(err, res, body) {
        var auth, metadata, stormdata, url;
        if (err) {
          util.log("request failed: " + err);
          if (!error) {
            error = true;
            return callback();
          }
        }
        try {
          util.log(("" + provider.name + " metadata http response statusCode: ") + res.statusCode);
          if (res.statusCode === 200) {
            metadata = JSON.parse(body);
            util.log("metadata: " + metadata);
            url = require('url').parse(metadata.meta.stormtracker);
            auth = url.auth;
            delete url.auth;
            stormdata = {
              provider: provider.name,
              skey: metadata.uuid,
              tracker: require('url').format(url),
              token: auth
            };
            if (stormdata.skey) return callback(stormdata);
          }
        } catch (error) {
          util.log(("check failed for " + provider.name + ": ") + error);
        }
        return callback();
      });
    };

    Environment.prototype.discover = function(callback) {
      var i, stormdata,
        _this = this;
      i = 0;
      stormdata = null;
      return async.until(function() {
        return i >= providers.length || (stormdata != null);
      }, function(repeat) {
        return _this.check(providers[i++], function(match) {
          if (match != null) stormdata = match;
          return setTimeout(repeat, 1000);
        });
      }, function(err) {
        if (err || !(stormdata != null)) {
          util.log("unable to discover the running provider environment!");
        }
        if (callback != null) return callback(stormdata);
      });
    };

    Environment.prototype.os = function() {
      return {
        tmpdir: os.tmpdir(),
        endianness: os.endianness(),
        hostname: os.hostname(),
        type: os.type(),
        platform: os.platform(),
        release: os.release(),
        arch: os.arch(),
        uptime: os.uptime(),
        loadavg: os.loadavg(),
        totalmem: os.totalmem(),
        freemem: os.freemem(),
        cpus: os.cpus(),
        networkInterfaces: os.networkInterfaces()
      };
    };

    return Environment;

  })();

  module.exports = new Environment;

}).call(this);

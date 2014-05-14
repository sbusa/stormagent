// Generated by CoffeeScript 1.7.1
(function() {
  this.include = function() {
    var schema, validate;
    validate = require('json-schema').validate;
    schema = {};
    this.get({
      '/': function() {
        var res, util;
        util = require('util');
        util.log("get / with agent: " + util.inspect(this.agent));
        res = this.agent.env.os();
        console.log(res);
        return this.send(res);
      }
    });
    this.get({
      '/environment': function() {
        var res;
        res = this.agent.env.os();
        console.log(res);
        return this.send(res);
      }
    });
    this.get({
      '/bolt': function() {
        var x;
        x = require('./activation').getBoltData();
        console.log(x);
        return this.send(x);
      }
    });
    schema.personality = {
      name: "personality",
      type: "object",
      items: {
        type: "object",
        additionalProperties: false,
        properties: {
          path: {
            type: "string",
            required: true
          },
          contents: {
            type: "string",
            required: true
          },
          postxfer: {
            type: "string"
          }
        }
      }
    };
    return this.post({
      '/personality': function() {
        var exec, fs, p, path, result, _fn, _i, _len, _ref;
        console.log('performing schema validation on incoming service JSON');
        result = validate(this.body, schema.personality);
        console.log(result);
        if (!result.valid) {
          return this.next(new Error("Invalid personality posting!: " + result.errors));
        }
        fs = require('fs');
        exec = require('child_process').exec;
        path = require('path');
        _ref = this.body.personality;
        _fn = function(p) {
          var dir;
          console.log("writing personality to " + p.path + "...");
          dir = path.dirname(p.path);
          if (!path.existsSync(dir)) {
            return exec("mkdir -p " + dir, (function(_this) {
              return function(error, stdout, stderr) {
                if (!error) {
                  return fs.writeFile(p.path, new Buffer(p.contents || '', "base64"), function() {
                    if (p.postxfer != null) {
                      return exec("" + p.postxfer, function(error, stdout, stderr) {
                        if (error) {
                          console.log("issuing '" + p.postxfer + "'... stderr: " + stderr);
                        }
                        if (!error) {
                          return console.log("issuing '" + p.postxfer + "'... stdout: " + stdout);
                        }
                      });
                    }
                  });
                }
              };
            })(this));
          } else {
            return fs.writeFile(p.path, new Buffer(p.contents || '', "base64"), function() {
              if (p.postxfer != null) {
                return exec("" + p.postxfer, function(error, stdout, stderr) {
                  if (error) {
                    console.log("issuing '" + p.postxfer + "'... stderr: " + stderr);
                  }
                  if (!error) {
                    return console.log("issuing '" + p.postxfer + "'... stdout: " + stdout);
                  }
                });
              }
            });
          }
        };
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          p = _ref[_i];
          _fn(p);
        }
        return this.send({
          result: 'success'
        });
      }
    });
  };

}).call(this);
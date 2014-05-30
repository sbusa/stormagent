(function() {

  this.include = function() {
    var agent, schema, validate;
    validate = require('json-schema').validate;
    schema = {};
    agent = this.settings.agent;
    this.get({
      '/': function() {
        return this.send(agent.status());
      }
    });
    this.get({
      '/environment': function() {
        var res;
        res = agent.env.os();
        console.log(res);
        return this.send(res);
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
          var dir,
            _this = this;
          console.log("writing personality to " + p.path + "...");
          dir = path.dirname(p.path);
          if (!path.existsSync(dir)) {
            return exec("mkdir -p " + dir, function(error, stdout, stderr) {
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
            });
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

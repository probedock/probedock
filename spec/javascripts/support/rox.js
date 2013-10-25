// Copyright (c) 2012-2013 Lotaris SA
//
// This file is part of ROX Center.
//
// ROX Center is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// ROX Center is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with ROX Center.  If not, see <http://www.gnu.org/licenses/>.

module.exports = function(grunt) {

  var _ = require('underscore'),
      fs = require('fs-extra'),
      http = require('http'),
      path = require('path'),
      url = require('url'),
      zlib = require('zlib');

  var config = JSON.parse(fs.readFileSync('./rox.json'));
  var sharedWorkspace = config.workspace;
  var workspace = path.join(config.workspace, 'jasmine');

  grunt.registerTask('rox-upload', function() {

    var done = this.async();
    var testRun = JSON.parse(fs.readFileSync(path.join(workspace, 'testRun.json')));

    processPayload(testRun, done);
  });

  grunt.registerMultiTask('rox', 'Run jasmine specs and send the results to ROX Center', function() {

    var taskConfig = this.data;
    if (taskConfig.category) {
      config.category = taskConfig.category;
    }
    if (taskConfig.tags) {
      config.tags = _.compact(_.union(_.isArray(config.tags) ? config.tags : [ config.tags ], _.isArray(taskConfig.tags) ? taskConfig.tags : [ taskConfig.tags ]));
    }
    if (taskConfig.tickets) {
      config.tickets = _.compact(_.union(_.isArray(config.tickets) ? config.tickets : [ config.tickets ], _.isArray(taskConfig.tickets) ? taskConfig.tickets : [ taskConfig.tickets ]));
    }

    var runnerKey = process.env.ROX_RUNNER_KEY;
    if (!runnerKey) {
      grunt.log.error('Runner key must be in the ROX_RUNNER_KEY environment variable');
      return false;
    }

    var testRun = {
      runnerKey : runnerKey,
      project : config.project,
      projectVersion : config.projectVersion,
      tests : []
    };

    loadUid(testRun);

    grunt.event.on('jasmine.reportRunnerStarting', function() {
      testRun.startTime = new Date().getTime();
    });

    grunt.event.on('jasmine.reportSpecResults', function(specId, result, fullName, duration, metadata) {
      testRun.tests.push(buildTest(specId, result, fullName, duration, metadata));
    });

    grunt.event.on('jasmine.reportRunnerResults', function() {

      testRun.endTime = new Date().getTime();
      testRun.duration = testRun.endTime - testRun.startTime;

      var json = JSON.stringify(testRun, null, 2);
      fs.mkdirsSync(workspace);
      fs.writeFileSync(path.join(workspace, 'testRun.json'), json, 'UTF-8');
    });

    grunt.task.run('jasmine', 'rox-upload');
  });

  function loadUid(testRun) {

    var sharedUidFile = path.join(sharedWorkspace, 'uid');
    var sharedUid = fs.existsSync(sharedUidFile) ? fs.readFileSync(sharedUidFile, 'UTF-8') : null;

    var lastUidFile = path.join(workspace, 'lastUid');
    var lastUid = fs.existsSync(lastUidFile) ? fs.readFileSync(lastUidFile, 'UTF-8') : null;

    if (sharedUid && lastUid && sharedUid == lastUid) {
      fs.unlinkSync(sharedUidFile);
    } else if (sharedUid) {
      fs.mkdirsSync(path.dirname(lastUidFile));
      fs.writeFileSync(lastUidFile, sharedUid, 'UTF-8');
      testRun.uid = sharedUid;
    }
  }

  function processPayload(testRun, done) {

    var payload = buildPayload(testRun);
    var contents = JSON.stringify(payload);
    var pretty = JSON.stringify(payload, null, 2);
    
    if (config.dumpPayload) {
      grunt.log.writeln();
      grunt.log.writeln(pretty);
      grunt.log.writeln();
    }

    fs.writeFileSync(path.join(workspace, 'payload.json'), pretty, 'UTF-8');

    if (!validateTestRun(testRun)) {
      return done(false);
    }

    var publish = config.publish && (!process.env.ROX_PUBLISH || process.env.ROX_PUBLISH == '1')
    if (!publish) {
      grunt.log.writeln('ROX publishing disabled');
      return done();
    }

    if (config.compress) {
      zlib.gzip(contents, function(err, compressed) {

        if (err) {
          grunt.log.error(err);
          return done(false);
        }

        uploadPayload(new Buffer(compressed).toString('base64'), done);
      });
    } else {
      uploadPayload(contents, done);
    }
  }

  function uploadPayload(contents, done) {

    var payloadUrl = url.parse(config.url);

    var options = {
      hostname : payloadUrl.hostname,
      port : payloadUrl.port,
      path : payloadPath(payloadUrl.path),
      method : 'POST',
      headers : {
        'Content-Type' : config.compress ? 'rox/compressed' : 'application/json',
        'Content-Length' : contents.length
      }
    };

    var req = http.request(options, function(res) {

      if (res.statusCode == 202) {
        grunt.log.writeln("Successfully sent results to ROX Center");
        done();
      } else {
        res.on('data', function(chunk) {
          grunt.log.error(chunk);
          done(false);
        });
      }
    });

    req.write(contents);
    req.end();
  }

  function payloadPath(base) {
    switch(config.apiVersion) {
      case 0 : return base;
      default : return path.join(base, 'v1', 'payload');
    }
  }

  function validateTestRun(testRun) {
    
    var keys = {};
    var testsMissingKey = [];
    var duplicatedKeys = {};

    _.each(testRun.tests, function(test) {
      if (!test.key || !test.key.length) {
        testsMissingKey.push(test.name);
      } else if (keys[test.key]) {
        if (!duplicatedKeys[test.key]) {
          duplicatedKeys[test.key] = [ keys[test.key] ];
        }
        duplicatedKeys[test.key].push(test.name);
      }
      keys[test.key] = test.name;
    });

    var valid = true;

    if (!testRun.project || !testRun.project.length) {
      valid = false;
      grunt.log.error("Project is not set in rox.json");
    }

    if (!testRun.projectVersion || !testRun.projectVersion.length) {
      valid = false;
      grunt.log.error("Project version is not set in rox.json");
    }

    if (testsMissingKey.length) {
      valid = false;
      grunt.log.error("The following tests do not have a key:\n- " + testsMissingKey.join("\n- "));
    }

    if (!_.isEmpty(duplicatedKeys)) {
      valid = false;
      grunt.log.error("The following keys are used by multiple tests:\n- " + _.map(duplicatedKeys, function(names, key) {
        return key + "\n  - " + names.join("\n  - ");
      }).join("\n- "));
    }

    return valid;
  }

  function buildPayload(testRun) {
    switch(config.apiVersion) {
      case 0 : return versionZeroPayload(testRun);
      default : return versionOnePayload(testRun);
    }
  }

  function versionZeroPayload(testRun) {
    return {
      runner : testRun.runnerKey,
      tests : _.map(testRun.tests, function(test) {

        var t = {
          key : test.key,
          name : test.name,
          project : testRun.project,
          result : {
            passed : test.passed,
            duration : test.duration,
            version : testRun.projectVersion
          }
        };

        if (test.message) {
          t.result.message = test.message;
        }

        return t;
      })
    };
  }

  function versionOnePayload(testRun) {

    var run = {
      r : testRun.runnerKey,
      e : testRun.endTime,
      d : testRun.duration,
      j : testRun.project,
      v : testRun.projectVersion,
      t : _.map(testRun.tests, function(test) {
  
        var t = {
          k : test.key,
          n : test.name,
          p : test.passed,
          d : test.duration
        };

        if (test.message) {
          t.m = test.message;
        }

        if (test.category) {
          t.c = test.category;
        }

        if (test.tags) {
          t.g = test.tags;
        }

        if (test.tickets) {
          t.t = test.tickets;
        }

        return t;
      })
    };

    if (testRun.uid) {
      run.u = testRun.uid;
    }

    return { r : [ run ] };
  }

  function buildTest(specId, result, fullName, duration, metadata) {
    
    var test = {
      key : getKey(fullName, metadata),
      name : fullName,
      passed : result.passed,
      duration : duration
    };

    if (!result.passed) {
      test.message = buildMessage(result);
    }

    setCategory(test, metadata);
    setTags(test, metadata);
    setTickets(test, metadata);

    return test;
  }

  function getKey(name, metadata) {
    return metadata.length && metadata[0].rox ? metadata[0].rox.key : null;
  }

  function setCategory(test, metadata) {
    var withCategory = _.find(metadata, function(meta) {
      return meta.rox && meta.rox.category;
    });
    if (withCategory || config.category) {
      test.category = withCategory ? withCategory.rox.category : config.category;
    }
  }

  function setTags(test, metadata) {
    var tags = _.union.apply(_, _.map(metadata, function(meta) {
      return meta.rox && meta.rox.tags ? (_.isArray(meta.rox.tags) ? meta.rox.tags : [ meta.rox.tags ]) : [];
    }));
    if (config.tags) {
      tags = _.union(tags, _.isArray(config.tags) ? config.tags : [ config.tags ]);
    }
    if (tags.length) {
      test.tags = tags;
    }
  }

  function setTickets(test, metadata) {
    var tickets = _.union.apply(_, _.map(metadata, function(meta) {
      return meta.rox && meta.rox.tickets ? (_.isArray(meta.rox.tickets) ? meta.rox.tickets : [ meta.rox.tickets ]) : [];
    }));
    if (config.tickets) {
      tickets = _.union(tickets, _.isArray(config.tickets) ? config.tickets : [ config.tickets ]);
    }
    if (tickets.length) {
      test.tickets = tickets;
    }
  }

  function buildMessage(result) {
    return _.map(result.messages, function(message) {
      return message.message;
    }).join("\n");
  };
};

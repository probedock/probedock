// Copyright (c) 2012-2014 Lotaris SA
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
      color = require('cli-color'),
      fs = require('fs-extra'),
      http = require('http'),
      inflection = require('inflection'),
      merge = require('deepmerge'),
      path = require('path'),
      temp = require('temp'),
      url = require('url'),
      uuid = require('node-uuid'); // TODO: remove if unused

  temp.track();
  var configFiles = [ path.join(process.env.HOME, '.rox', 'config.yml'), path.join('.', 'rox.yml') ];

  function loadConfig(data) {

    // TODO: log warning if yaml is invalid
    var config = _.reduce(configFiles, function(memo, path) {
      if (fs.existsSync(path)) {
        memo = merge(memo, grunt.file.readYAML(path));
      }
      return memo;
    }, {});

    if (data.roxConfig) {
      config = merge(config, data.roxConfig);
    }

    // TODO: parse environment variables

    return config;
  };

  function setForce(force) {
    if (force && !grunt.option('force')) {
      grunt.config.set('rox:force', true);
      grunt.option('force', true);
    } else if (!force && grunt.config.get('rox:force')) {
      grunt.option('force', false);
      grunt.config.set('rox:force', false);
    }
  };

  //var config = JSON.parse(fs.readFileSync('./rox.json'));
  //var sharedWorkspace = config.workspace;
  //var workspace = path.join(config.workspace, 'jasmine');

  /*grunt.registerTask('rox-upload', function() {

    var done = this.async();
    var testRun = JSON.parse(fs.readFileSync(path.join(workspace, 'testRun.json')));

    processPayload(testRun, done);
  });*/

  grunt.registerMultiTask('rox-setup', 'Set up ROX Center client', function() {

    var config = loadConfig(this.data);

    var tmpDir = process.env.ROX_GRUNT_TMP;
    if (!process.env.ROX_GRUNT_TMP) {
      tmpDir = temp.mkdirSync();
      process.env['ROX_GRUNT_TMP'] = tmpDir;
    }

    tmpDir = path.join(tmpDir, this.target);
    fs.mkdirSync(tmpDir);

    setForce(true);

    var testRun = {
      project: config.project.apiId,
      projectName: config.project.name,
      projectVersion: config.project.version,
      tests: []
    };

    grunt.event.on('jasmine.reportRunnerStarting', function() {
      testRun.startTime = new Date().getTime();
    });

    grunt.event.on('jasmine.reportSpecResults', function(specId, result, fullName, duration, metadata) {
      testRun.tests.push(buildTest(config, result, fullName, duration, metadata));
    });

    grunt.event.on('jasmine.reportRunnerResults', function() {

      testRun.endTime = new Date().getTime();
      testRun.duration = testRun.endTime - testRun.startTime;
      
      var gruntData = {
        config: config,
        testRun: testRun
      };

      fs.writeFileSync(path.join(tmpDir, 'data.json'), JSON.stringify(gruntData), 'UTF-8');
    });
  });

  grunt.registerMultiTask('rox-publish', 'Publish test results to ROX Center', function() {

    setForce(false);

    if (!process.env.ROX_GRUNT_TMP) {
      throw new Error('The ROX_GRUNT_TMP environment variable must be set. You might have forgotten to run the rox_setup task.');
    }

    // TODO: allow to customize target
    var tmpDir = path.join(process.env.ROX_GRUNT_TMP, this.target);
    // TODO: check tmp dir exists and data valid
    var data = grunt.file.readJSON(path.join(tmpDir, 'data.json'));

    var config = data.config,
        testRun = data.testRun;

    var done = this.async();
    var payload = buildPayload(testRun);
    done();
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
    return versionOnePayload(testRun);
  }

  function versionOnePayload(testRun) {

    var run = {
      d : testRun.duration,
      r : [
        {
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
        }
      ]
    };

    if (testRun.uid) {
      run.u = testRun.uid;
    }

    return run;
  }

  function buildTest(config, result, fullName) {
    
    var test = {
      key : getKey(fullName, result.metadata),
      name : fullName,
      passed : result.passed,
      duration : result.duration
    };

    if (!result.passed) {
      test.message = buildMessage(result);
    }

    setCategory(test, config, result.metadata);
    setTags(test, config, result.metadata);
    setTickets(test, config, result.metadata);

    return test;
  }

  function getKey(name, metadata) {
    return metadata.length && metadata[0].rox ? metadata[0].rox.key : null;
  }

  function setCategory(test, config, metadata) {
    var withCategory = _.find(metadata, function(meta) {
      return meta.rox && meta.rox.category;
    });
    if (withCategory || config.category) {
      test.category = withCategory ? withCategory.rox.category : config.category;
    }
  }

  function setTags(test, config, metadata) {
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

  function setTickets(test, config, metadata) {
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

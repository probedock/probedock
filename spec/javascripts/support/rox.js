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
      https = require('https'),
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

    var uid = loadUid(config);
    if (uid) {
      testRun.uid = uid;
    }

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
    processTestRun(testRun, config, done);
  });

  function loadUid(config) {

    if (process.env.ROX_TEST_RUN_UID) {
      return process.env.ROX_TEST_RUN_UID;
    }

    var uidFile = path.join(config.workspace, 'uid');
    return fs.existsSync(uidFile) ? fs.readFileSync(uidFile, 'utf8').split('\n')[0] : null;
  }

  function processTestRun(testRun, config, done) {

    var payload = buildPayload(testRun);
    var contents = JSON.stringify(payload);
    var pretty = JSON.stringify(payload, null, 2);
    
    if (config.payload && config.payload.print) {
      grunt.log.writeln();
      grunt.log.writeln(pretty);
      grunt.log.writeln();
    }

    if (!validateTestRun(testRun)) {
      return done(false);
    }

    var sharedWorkspace = config.workspace,
        workspace = path.join(sharedWorkspace, 'jasmine');

    fs.writeFileSync(path.join(workspace, 'payload.json'), pretty, 'utf8');

    var publish = config.publish && (!process.env.ROX_PUBLISH || process.env.ROX_PUBLISH == '1')
    if (!publish) {
      grunt.log.writeln('ROX publishing disabled');
      return done();
    }

    publishPayload(contents, config, done);
  }

  function publishPayload(payload, config, done) {

    var server = config.servers[config.server];
    
    getPayloadResourceUrl(server, function(err, payloadResourceUrl) {
      if (err) {
        grunt.log.error(err);
        return done(false);
      }

      grunt.log.writeln('Connected to ROX Center API at ' + server.apiUrl);

      uploadPayload(payload, payloadResourceUrl, config, function(err) {
        if (err) {
          grunt.log.error(err);
          return done(false);
        }

        grunt.log.writeln('Successfully published test payload.');
        done();
      });
    });
  }

  function uploadPayload(payload, payloadResourceUrl, config, callback) {

    var payloadUrl = url.parse(payloadResourceUrl),
        server = config.servers[config.server],
        options = {
          hostname: payloadUrl.hostname,
          port: payloadUrl.port,
          path: payloadUrl.path,
          method: 'POST',
          headers: {
            'Content-Type': 'application/vnd.lotaris.rox.payload.v1+json',
            'Content-Length': payload.length,
            'Authorization': 'RoxApiKey id="' + server.apiKeyId + '" secret="' + server.apiKeySecret + '"'
          }
        };

    var req = (payloadUrl.protocol == 'https:' ? https : http).request(options, function(res) {

      var body = '';
      res.on('data', function(chunk) {
        body += chunk;
      });

      res.on('end', function() {
        if (res.statusCode != 202) {
          callback(new Error('Server responded with unexpected status code ' + res.statusCode + ' (response: ' + body + ')'));
        } else {
          callback();
        }
      });
    });

    req.on('error', callback);
    req.write(payload);
    req.end();
  }

  function getPayloadResourceUrl(server, callback) {

    var apiUrl = url.parse(server.apiUrl),
        options = {
          hostname: apiUrl.hostname,
          port: apiUrl.port,
          path: apiUrl.path,
          method: 'GET',
          headers: {
            'Accept': 'application/hal+json',
            'Authorization': 'RoxApiKey id="' + server.apiKeyId + '" secret="' + server.apiKeySecret + '"'
          }
        };

    var req = (apiUrl.protocol == 'https:' ? https : http).request(options, function(res) {

      var body = '';
      res.on('data', function(chunk) {
        body += chunk;
      });

      res.on('end', function() {
        if (res.statusCode != 200) {
          callback(new Error('Server responded with unexpected status code ' + res.statusCode + ' (response: ' + body + ')'));
        } else {
          try {
            callback(undefined, parsePayloadResourceUrl(body));
          } catch(e) {
            callback(e);
          }
        }
      });
    });

    req.on('error', callback);
    req.end();
  }

  function parsePayloadResourceUrl(body) {

    var apiRoot = JSON.parse(body);

    var links = apiRoot._links;
    if (!links) {
      throw new Error('Expected ROX Center API root to have _links property (response: ' + body + ')');
    }
    
    var testPayloadsLink = links['v1:test-payloads'];
    if (!testPayloadsLink) {
      throw new Error('Expected ROX Center API root to have link v1:test-payloads (response: ' + body + ')');
    }

    var href = testPayloadsLink.href;
    if (!href) {
      throw new Error('Expected ROX Center API root v1:test-payloads link to have an href property (response: ' + body + ')');
    }

    return href;
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
      grunt.log.error("Project is not set");
    }

    if (!testRun.projectVersion || !testRun.projectVersion.length) {
      valid = false;
      grunt.log.error("Project version is not set");
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
    if (withCategory || (config.project && config.project.category)) {
      test.category = withCategory ? withCategory.rox.category : config.project.category;
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

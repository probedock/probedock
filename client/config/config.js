var path = require('path'),
    rootPath = path.normalize(__dirname + '/..'),
    env = process.env.NODE_ENV || 'development';

var liveReloadPort = process.env.LIVERELOAD_PORT || 35729;

var config = {
  development: {
    root: rootPath,
    port: 3000,
    backendProxyHost: 'localhost:3010',
    liveReloadPort: liveReloadPort,
    liveReloadUrl: 'http://localhost:' + liveReloadPort + '/livereload.js'
  },

  test: {
    root: rootPath,
    port: 3000,
    backendProxyHost: 'localhost:3010'
  },

  production: {
    root: rootPath
  }
};

module.exports = config[env];
module.exports.env = env;

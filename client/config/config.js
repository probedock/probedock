var _ = require('underscore'),
    env = process.env.NODE_ENV || 'development',
    path = require('path');

var liveReloadPort = process.env.LIVERELOAD_PORT || 35729,
    pkg = require(path.join('..', 'package')),
    root = path.normalize(path.join(__dirname, '..'));

var config = {
  development: {
    port: process.env.PORT || 3000,
    backendProxyHost: process.env.PROBEDOCK_BACKEND_PROXY || 'localhost:3010',
    liveReloadPort: liveReloadPort,
    liveReloadUrl: 'http://localhost:' + liveReloadPort + '/livereload.js'
  },

  test: {
    port: process.env.PORT || 3000,
    backendProxyHost: process.env.PROBEDOCK_BACKEND_PROXY || 'localhost:3010'
  },

  production: {
    port: process.env.PORT || 3000,
    backendProxyHost: process.env.PROBEDOCK_BACKEND_PROXY || 'localhost:3010'
  }
};

module.exports = _.extend(config[env], {
  env: env,
  root: root,
  version: pkg.version
});

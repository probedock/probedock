var _ = require('underscore'),
    config = require('../config/config'),
    fs = require('fs'),
    glob = require('glob'),
    minimatch = require('minimatch'),
    path = require('path'),
    yml = require('js-yaml');

var assets = {},
    updated = false,
    loadPaths = [];

exports.getAssets = function(type) {
  if (!updated) {
    updateAssets();
    updated = true;
  }

  return assets[type] || [];
};

function updateAssets() {
  var manifestsConfig = yml.safeLoad(fs.readFileSync(config.root + '/manifests.yml', { encoding: 'utf-8' }));

  _.each(manifestsConfig.manifests || [], function(manifest, name) {

    var type = manifest.type || name,
        extensionRegexp = new RegExp('\\.' + type + '$');

    assets[type] = [];

    var loadPaths = _.map(manifest.paths || [], function(loadPath) {
      return {
        path: loadPath,
        assets: _.map(glob.sync(config.root + '/' + loadPath + '/**/*.' + type), function(filePath) {
          return path.relative(loadPath, filePath);
        })
      };
    });

    _.each(manifest.assets || [], function(logicalName) {

      var relativePath = !!logicalName.match(extensionRegexp) ? logicalName : logicalName + '.' + type;

      var loadPath = _.find(loadPaths, function(loadPath) {
        return _.contains(loadPath.assets, relativePath);
      });

      var found = false;

      if (loadPath) {
        assets[type].push({
          dirname: loadPath.path,
          path: relativePath,
          logicalPath: logicalName
        });

        found = true;
        return;
      }

      _.each(loadPaths, function(loadPath) {
        _.each(loadPath.assets, function(asset) {
          if (minimatch(asset, relativePath)) {
            if (!_.findWhere(assets[type], { path: asset })) {
              assets[type].push({
                dirname: loadPath.path,
                path: asset,
                logicalPath: asset.replace(extensionRegexp, '')
              });

              found = true;
            }
          }
        });
      });

      if (!found) {
        throw new Error('Could not find ' + type + ' asset ' + logicalName + ' in ' + _.pluck(loadPaths, 'path'));
      }
    });
  });
};

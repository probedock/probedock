var _ = require('underscore'),
    fs = require('fs'),
    minimatch = require('minimatch'),
    p = require('bluebird'),
    path = require('path'),
    yml = require('js-yaml');

var glob = p.promisify(require('glob')),
    readFile = p.promisify(fs.readFile),
    writeFile = p.promisify(fs.writeFile);

function AssetManager(options) {
  options = _.defaults({}, options, {
    config: 'manifests.yml'
  });

  this.manifests = null;
  this.configFile = options.config;
}

_.extend(AssetManager.prototype, {
  getManifest: function(name) {
    return this.manifests[name];
  },

  init: function() {
    return p.resolve()
      .then(_.partial(ensureConfigLoaded, this))
      .then(_.partial(ensureAssetsScanned, this))
      .return(this);
  },

  add: function(files) {

    var manifests = this.manifests;

    _.each(files, function(file) {
      _.each(manifests, function(manifest) {
        _.each(manifest.assets, function(assetConfig) {

          var loadPath = _.find(manifest.paths, function(loadPath) {
            var pattern = path.join(loadPath.root, loadPath.base, assetConfig.path);
            return minimatch(file, pattern);
          });

          if (loadPath) {

            var relativePath = path.relative(loadPath.base, file);
            if (_.findWhere(assetConfig.files, { path: relativePath })) {
              return;
            }

            assetConfig.files.push({
              path: relativePath
            });

            assetConfig.files.sort();

            console.log('Added ' + relativePath + ' to ' + assetConfig.path + ' in manifest ' + manifest.name);
          }
        });
      });
    });

    return p.resolve();
  },

  remove: function(files) {

    var manifests = this.manifests;

    _.each(files, function(file) {
      _.each(manifests, function(manifest) {
        _.each(manifest.assets, function(assetConfig) {

          var loadPath = _.find(manifest.paths, function(loadPath) {
            var pattern = path.join(loadPath.root, loadPath.base, assetConfig.path);
            return minimatch(file, pattern);
          });

          if (loadPath) {

            var relativePath = path.relative(loadPath.base, file),
                matchingFile = _.findWhere(assetConfig.files, { path: relativePath }),
                index = assetConfig.files.indexOf(matchingFile);

            assetConfig.files.splice(index, 1);

            console.log('Removed ' + relativePath + ' from ' + assetConfig.path + ' in manifest ' + manifest.name);
          }
        });
      });
    });

    return p.resolve();
  }
});

exports.assetManager = function(options) {
  return new AssetManager(options);
};

function ensureAssetsScanned(manager) {
  return p.all(_.map(_.filter(manager.manifests, function(manifest) {
    return !manifest.files;
  }), scanManifestAssets));
}

function scanAssets(manager) {
  return p.all(_.reduce(manager.manifests, function(memo, manifest) {
    memo.push(scanManifestAssets(manifest));
    return memo;
  }, []));
}

function scanManifestAssets(manifest) {
  return p.all(_.map(manifest.assets, function(assetConfig) {
    return scanAssetConfig(assetConfig, manifest);
  })).then(function() {
    updateManifestFiles(manifest);
  });
}

function updateManifestFiles(manifest) {
  manifest.files = [];

  _.each(manifest.assets, function(assetConfig) {
    manifest.files = manifest.files.concat(assetConfig.files);
  });
}

function scanAssetConfig(assetConfig, manifest) {
  return p.reduce(manifest.paths, function(memo, loadPath) {
    if (memo) {
      return memo;
    }

    var globPattern = path.join(loadPath.path, assetConfig.path);
    return glob(globPattern).then(function(files) {
      if (!files.length) {
        return null;
      }

      return {
        files: files,
        loadPath: loadPath,
        assetConfig: assetConfig
      };
    });
  }, null).then(function(result) {
    if (!result) {
      throw new Error('No asset found for ' + JSON.stringify(assetConfig));
    }

    assetConfig.files = _.map(result.files, function(file) {
      return {
        path: path.relative(result.loadPath.base, file)
      };
    });

    return assetConfig;
  });
}

function ensureConfigLoaded(manager) {
  if (manager.manifests) {
    return p.resolve(manager);
  }

  return loadConfig(manager).then(function(config) {
    return _.extend(manager, config);
  });
}

function expandConfig(config, manager) {

  var configDir = path.dirname(manager.configFile);
  config.root = path.resolve(configDir, config.root || configDir);
  config.base = config.base || config.root;

  config.manifests = _.reduce(config.manifests, function(memo, manifestConfig, manifestName) {
    memo[manifestName] = expandManifestConfig(manifestConfig, manifestName, config);
    return memo;
  }, {});

  return config;
}

function expandManifestConfig(manifestConfig, manifestName, config) {

  var manifest = _.extend(manifestConfig, {
    name: manifestName,
    type: manifestConfig.type || manifestName
  });

  _.defaults(manifest, _.pick(config, 'root', 'base'));

  manifest.paths = _.map(manifestConfig.paths || [], function(loadPathConfig) {
    return expandLoadPathConfig(loadPathConfig, manifest);
  });

  manifest.assets = _.map(manifestConfig.assets || [], function(assetsConfig) {
    return expandAssetsConfig(assetsConfig, manifest);
  });

  return manifest;
}

function expandLoadPathConfig(loadPathConfig, manifest) {

  var loadPath = loadPathConfig;
  if (_.isString(loadPath)) {
    loadPath = {
      path: loadPath
    };
  }

  if (!loadPath.path) {
    throw new Error('Load path ' + JSON.stringify(loadPathConfig) + ' has no path');
  }

  _.defaults(loadPath, _.pick(manifest, 'root', 'base'));

  return loadPath;
}

function expandAssetsConfig(assetsConfig, manifest) {

  var assets = assetsConfig;
  if (_.isString(assetsConfig)) {
    assets = {
      path: assets
    };
  }

  if (!assets.path) {
    throw new Error('Assets configuration ' + JSON.stringify(assetsConfig) + ' has no path');
  }

  assets.path = assets.path + '.' + manifest.type;

  return assets;
}

function loadConfig(manager) {
  return p.resolve(manager.configFile).then(function(file) {
    return readFile(file, { encoding: 'utf-8' });
  }).then(function(contents) {
    return yml.safeLoad(contents);
  }).then(function(config) {
    return expandConfig(config, manager);
  });
}

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

var _ = require('underscore'),
    manifests = require('./manifests'),
    config = require('../config/config');

var root = config.root;

function manifestAssetTags(manifest) {

  var assetList = manifest.files;

  return _.map(assetList, function(asset) {
    if (manifest.type == 'css') {
      return '<link rel="stylesheet" media="all" href="/' + asset.path + '">';
    } else if (manifest.type == 'js') {
      return '<script src="/' + asset.path + '"></script>';
    }
  }).join("\n");
}

module.exports = function(assetManager) {
  return _.extend({}, config, {
    css: function() {
      return manifestAssetTags(assetManager.getManifest('css'));
    },

    js: function() {
      return manifestAssetTags(assetManager.getManifest('js'));
    }
  });
};

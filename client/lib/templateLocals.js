var _ = require('underscore'),
    manifests = require('./manifests'),
    config = require('../config/config');

var root = config.root;

function manifestAssetTags(type) {

  var assetList = manifests.getAssets(type);

  return _.map(assetList, function(asset) {
    if (type == 'css') {
      return '<link rel="stylesheet" media="all" href="/' + asset.path + '">';
    } else if (type == 'js') {
      return '<script src="/' + asset.path + '"></script>';
    }
  }).join("\n");
}

module.exports = _.extend({}, config, {
  css: function() {
    return manifestAssetTags('css');
  },

  js: function() {
    return manifestAssetTags('js');
  }
});

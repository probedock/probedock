var _ = require('underscore'),
    assets = require('./assets'),
    config = require('../config/config');

var root = config.root;

function assetTags(type) {

  var assetList = assets.getAssets(type);

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
    return assetTags('css');
  },

  js: function() {
    return assetTags('js');
  }
});

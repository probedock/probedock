
var SpecHelpers = SpecHelpers || {}

SpecHelpers.modules = {
    
  loadModule: function(name, configs) {

    loadFixtures('layout.html');

    var n = 1;
    if (!_.isArray(configs)) {
      configs = [ configs ];
      n = false;
    }

    var injections = _.map(configs, function(config) {

      var id = name + 'Fixture' + (n ? n++ : '');
      $('<div class="moduleFixture" />').attr('id', id).attr('data-module', name).attr('data-config', JSON.stringify(config)).appendTo($('body'));
    });

    App.startAutoModules(name);
  },

  unloadModule: function(name) {
    App.module(name).stop();
    $('.moduleFixture').remove();
  }
};

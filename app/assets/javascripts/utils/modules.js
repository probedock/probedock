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

// ROX Center javascript code is divided into custom Backbone Marionette modules called "auto modules".
// Auto modules are not started with the Marionette application by default. Instead they have a name and
// are only started if the page contains one or multiple elements with a data-module attribute containing
// that name.
//
// For example, a "user" module will be started if the page contains the following markup:
//     <div data-module="user" />
//
// An auto module is defined with the `autoModule` method rather than `module`.
// It takes a name, a module definition function and options. Available options are:
//
// * `fade` - If true, the region passed to the initializer (see below) will fade in when shown.
//
// Auto modules should call `addAutoInitializer` in their definition. The passed function will be called
// with an options object containing the following properties:
//
// * `region` - The Backbone Marionette Region where the module should be shown.
// * `config` - The value of the data-config attribute of the DOM element.
//
// The function may be called multiple times if multiple DOM elements have the same name in their
// data-module attribute.

App.autoModules = {};

// Defines an auto module with the specified name.
App.autoModule = function(name, definition, options) {

  if (App.autoModules[name]) {
    throw new Error('The "' + name + '" module is already defined');
  }

  App.autoModules[name] = {
    module: App.module(name, { startWithParent: false, define: definition }),
    options: options
  };
};

// Configures an initializer function that will be called once for each
// DOM element matching the auto module's name.
Marionette.Module.prototype.addAutoInitializer = function(func) {

  this.addInitializer(function(options) {

    _.each(options.injections, function(injection) {
      func(injection);
    });
  });
};

Backbone.Marionette.FadeInRegion = Backbone.Marionette.Region.extend({

  open: function(view) {
    this.$el.hide();
    this.$el.html(view.el);
    this.$el.fadeIn('fast');
  }
});

App.startAutoModules = function() {

  var names = Array.prototype.slice.call(arguments);
  if (!names.length) {
    names = _.keys(App.autoModules);
  }

  _.each(_.pick(App.autoModules, names), function(data, name) {

    var module = data.module,
        options = data.options,
        el = $('[data-module="' + name + '"]');

    if (el.length) { // at least one matching DOM element found

      var injections = el.map(function() {

        var regionClass = Backbone.Marionette.Region;
        if (options && options.fade) {
          regionClass = Backbone.Marionette.FadeInRegion;
        }

        return { region: new regionClass({ el: $(this) }), config: $(this).data('config') };
      });

      module.start({ injections: injections });
    }
  });
};

// Starts all auto modules with matching DOM elements.
App.addInitializer(function() {
  App.startAutoModules();
});

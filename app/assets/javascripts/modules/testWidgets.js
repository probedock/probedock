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
App.autoModule('testWidgets', function() {

  var Controller = Marionette.Controller.extend({

    initialize: function(options) {
      this.projectVersions = new App.components.TestProjectVersions({ model: options.model });
    }
  });

  var TestWidget = Backbone.Model.extend({

    relations: [
      {
        type: Backbone.HasOne,
        key: 'test',
        relatedModel: App.models.Test
      }
    ]
  });

  var TestWidgetDataCollection = Backbone.Collection.extend({
    model: TestWidget
  });

  var Layout = Marionette.CompositeView.extend({

    template: 'widgets/layout',
    childView: App.views.TestWidgetContainer,
    childViewContainer: '.row',

    childViewOptions: function() {
      return { controller: this.controller };
    },

    ui: {
      columns: '.row .col-md-6'
    },

    initialize: function(options) {
      this.controller = options.controller;
    },

    initRenderBuffer: function() {
      Marionette.CompositeView.prototype.initRenderBuffer.apply(this, Array.prototype.slice.call(arguments));
      this.elBuffer = [ $('<div />'), $('<div />') ];
    },

    attachBuffer: function(compositeView, buffer) {
      this.ui.columns.each(function(index) {
        $(this).html(buffer[index % 2].children());
      });
    },

    attachHtml: function(compositeView, childView, index){
      if (compositeView.isBuffering) {
        compositeView.elBuffer[index % 2].append(childView.el);
        compositeView._bufferedChildren.push(childView);
      } else {
        this.ui.columns.find(':nth-child(' + ((index % 2) + 1) + ')').append(childView.el);
      }
    }
  });

  App.addTestWidget = function(name, marionetteClass, definition) {

    var translate = function() {
      var args = Array.prototype.slice.call(arguments);
      args[0] = 'jst.testWidgets.' + name + '.' + args[0];
      return I18n.t.apply(I18n, args);
    };

    App.module('testWidgets', function() {

      this[name.underscore().camelize()] = marionetteClass.extend(_.extend({

        widget: name,
        className: 'testWidgetBody',

        templateHelpers: {
          t: translate
        },

        initialize: function(options) {

          this.template = 'widgets/test/' + this.widget + '/template';

          if (options && options.controller) {
            this.controller = options.controller;
          }

          if (typeof(this.initializeWidget) == 'function') {
            this.initializeWidget.apply(this, Array.prototype.slice.call(arguments));
          }
        },

        t: translate
      }, definition));
    });
  };

  this.addAutoInitializer(function(options) {

    var test = new App.models.Test(options.config.test),
        controller = new Controller({ model: test });

    var widgetsData = new TestWidgetDataCollection(_.reduce(options.config.widgets, function(memo, data, name) {

      var widget = new TestWidget(_.extend(data, { id: name }));
      widget.set({ test: test }, { silent: true });

      memo.push(widget);
      return memo;
    }, []));

    options.region.show(new Layout({ model: test, collection: widgetsData, controller: controller }));
  });
});

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

  var HalModel = App.module('models').HalModel;

  var HalUser = HalModel.extend({

    halLinks: [ 'alternate' ]
  });

  var HalProject = HalModel.extend({

    halLinks: [ 'self', 'alternate' ]
  });

  var HalCategory = HalModel.extend({

    halLinks: [ 'search' ]
  });

  var HalTag = HalModel.extend({

    halLinks: [ 'search' ]
  });

  var HalTicket = HalModel.extend({

    halLinks: [ 'about', 'search' ],

    ticketHref: function() {
      return this.hasLink('about') ? this.link('about').get('href') : this.link('search').get('href');
    }
  });

  var HalTestEmbedded = Backbone.RelationalModel.extend({
  });

  var HalTest = HalModel.extend({

    halLinks: [ 'bookmark' ],
    halEmbedded: [
      {
        type: Backbone.HasOne,
        key: 'v1:author',
        relatedModel: HalUser
      },
      {
        type: Backbone.HasOne,
        key: 'v1:project',
        relatedModel: HalProject
      },
      {
        type: Backbone.HasOne,
        key: 'v1:category',
        relatedModel: HalCategory
      },
      {
        type: Backbone.HasMany,
        key: 'v1:tags',
        relatedModel: HalTag
      },
      {
        type: Backbone.HasMany,
        key: 'v1:tickets',
        relatedModel: HalTicket
      }
    ]
  });

  var TestWidget = Backbone.Model.extend({

    relations: [
      {
        type: Backbone.HasOne,
        key: 'test',
        relatedModel: HalTest
      }
    ]
  });

  var TestWidgetDataCollection = Backbone.Collection.extend({
    model: TestWidget
  });

  var Layout = Marionette.CompositeView.extend({

    template: 'widgets/layout',
    itemView: App.module('views').TestWidgetContainer,
    itemViewContainer: '.row',

    ui: {
      columns: '.row .col-md-6'
    },

    initRenderBuffer: function() {
      Marionette.CompositeView.prototype.initRenderBuffer.apply(this, Array.prototype.slice.call(arguments));
      this.elBuffer = [ $('<div />'), $('<div />') ];
    },

    appendBuffer: function(compositeView, buffer) {
      this.ui.columns.each(function(index) {
        $(this).html(buffer[index].children());
      });
    },

    appendHtml: function(compositeView, itemView, index){
      if (compositeView.isBuffering) {
        compositeView.elBuffer[index].append(itemView.el);
        compositeView._bufferedChildren.push(itemView);
      } else {
        this.ui.columns.find(':nth-child(' + (index + 1) + ')').append(itemView.el);
      }
    }
  });

  App.addTestWidget = function(name, marionetteClass, definition) {

    App.module('testWidgets', function() {

      this[name.underscore().camelize()] = marionetteClass.extend(_.extend({

        widget: name,
        className: 'testWidgetBody',
        
        initialize: function() {

          this.template = 'widgets/test/' + this.widget + '/template';

          if (typeof(this.initializeWidget) == 'function') {
            this.initializeWidget.apply(this, Array.prototype.slice.call(arguments));
          }
        },

        t: function() {
          var args = Array.prototype.slice.call(arguments);
          args[0] = 'jst.testWidgets.' + this.widget + '.' + args[0];
          return I18n.t.apply(I18n, args);
        }
      }, definition));
    });
  };

  this.addAutoInitializer(function(options) {

    var test = new HalTest(options.config.test);

    var widgetsData = new TestWidgetDataCollection(_.reduce(options.config.widgets, function(memo, data, name) {

      var widget = new TestWidget(_.extend(data, { id: name }));
      widget.set({ test: test }, { silent: true });

      memo.push(widget);
      return memo;
    }, []));

    options.region.show(new Layout({ model: test, collection: widgetsData }));
  });
});

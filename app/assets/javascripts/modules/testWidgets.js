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
  });

  var HalProject = HalModel.extend({
  });

  var HalCategory = HalModel.extend({
  });

  var HalTag = HalModel.extend({
  });

  var HalTicket = HalModel.extend({

    ticketHref: function() {
      var aboutLink = this.get('_links').about;
      return aboutLink ? aboutLink.href : this.get('_links')['search'].href;
    }
  });

  var HalTestEmbedded = Backbone.RelationalModel.extend({

    relations: [
      {
        type: Backbone.HasOne,
        key: 'author',
        keySource: 'v1:author',
        relatedModel: HalUser
      },
      {
        type: Backbone.HasOne,
        key: 'project',
        keySource: 'v1:project',
        relatedModel: HalProject
      },
      {
        type: Backbone.HasOne,
        key: 'category',
        keySource: 'v1:category',
        relatedModel: HalCategory
      },
      {
        type: Backbone.HasMany,
        key: 'tags',
        keySource: 'v1:tags',
        relatedModel: HalTag
      },
      {
        type: Backbone.HasMany,
        key: 'tickets',
        keySource: 'v1:tickets',
        relatedModel: HalTicket
      }
    ]
  });

  var HalTest = HalModel.extend({

    relations: [
      {
        type: Backbone.HasOne,
        key: 'embedded',
        keySource: '_embedded',
        relatedModel: HalTestEmbedded
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

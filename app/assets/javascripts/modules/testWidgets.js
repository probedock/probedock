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

  var HalTag = HalModel.extend({
  });

  var HalTicket = HalModel.extend({

    ticketHref: function() {
      var describedByLink = this.get('_links').describedby;
      return describedByLink ? describedByLink.href : this.get('_links')['v1:tests'].href;
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
    itemViewContainer: '.col-md-6'
  });

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

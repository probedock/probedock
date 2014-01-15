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

App.autoModule('tagCloud', function() {

  var TagInfo = Backbone.Model.extend({

    path : function() {
      return Path.build('tests?' + $.param({ tags : [ this.get('name') ] }));
    }
  });

  var TagCloud = Backbone.Collection.extend({

    url : LegacyApiPath.builder('tags', 'cloud'),
    model : TagInfo,

    comparator : function(a, b) {
      return a.get('name').localeCompare(b.get('name'));
    },

    parse : function(models, options) {
      if (options.xhr.status == 304) {
        return this.models.slice();
      }
      return models;
    }
  });

  var TagInfoView = Backbone.Marionette.ItemView.extend({
    
    tagName : 'a',
    template : false,

    onRender : function() {
      this.$el.text(this.model.get('name'));
      this.$el.attr('href', this.model.path());
      this.$el.attr('rel', this.model.get('count'));
    }
  });

  var TagCloudView = Backbone.Marionette.CompositeView.extend({

    tagName : 'div',
    className : 'tagCloud well',
    template : false,
    itemView : TagInfoView,

    initialize : function(options) {
      this.total = options.total;
      this.maxSize = options.size;
      App.watchStatus(this, this.update, { only: 'lastApiPayload' });
    },

    update : function() {
      this.collection.fetch({
        ifModified : true,
        data : {
          size : this.maxSize
        }
      }).done(_.bind(function() {
        App.debug('Updated tag cloud after new activity');
        this.setupTagCloud();
      }, this));
    },

    onRender : function() {
      this.setupTagCloud();
      if (this.total && this.total > this.collection.length) {
        this.addAllTags();
      }
    },

    addAllTags : function() {
      this.$el.prepend(_.template('<a class="all btn btn-info btn-small pull-right" href="<%= path %>">All Tags</a>', { path : Path.build('tags') }));
    },

    appendHtml: function(collectionView, itemView, index){
      collectionView.$el.append(itemView.el);
      collectionView.$el.append(' ');
    },

    setupTagCloud : function() {
      this.$el.find('a:not(.all)').tagcloud();
    }
  });

  this.addAutoInitializer(function(options) {
    options.region.show(new TagCloudView(_.extend(_.pick(options.config, 'size', 'total'), { collection : new TagCloud(options.config.cloud) })));
  });
});

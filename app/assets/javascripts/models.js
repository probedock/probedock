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
App.module('models', function() {

  var HalLink = Backbone.RelationalModel.extend({

    idAttribute: 'href',

    tag: function(contents, options) {
      options = options || {};
      return $('<a />').attr('href', this.get('href'))[options.html ? 'html' : 'text'](contents);
    }
  });

  var HalLinkCollection = Backbone.Collection.extend({
  });

  var HalModelLinks = Backbone.RelationalModel.extend({

    link: function(rel, options) {
      options = _.defaults({}, options, { required: true });

      if (options.required && !this.has(rel)) {
        throw new Error('No link found with relation ' + rel);
      }

      var links = this.get(rel);
      if (typeof(links.length) == 'undefined') {
        return links;
      }

      var type = options.type;
      var matching = links.filter(function(link) {
        return link.get('type') != null && link.get('type') == type;
      });

      if (!matching.length) {
        throw new Error('No link found with relation ' + rel + ' and type ' + type);
      } else if (matching.length >= 2) {
        throw new Error('Multiple links found with relation ' + rel + ' and type ' + type);
      }

      return _.first(matching);
    }
  });

  var HalModelEmbedded = Backbone.RelationalModel.extend({

    embedded: function(rel) {
      return this.get(rel);
    }
  });

  var HalModel = this.HalModel = Backbone.RelationalModel.extend({

    url: function() {
      return this.hasLink('self') ? this.link('self').get('href') : null;
    },

    link: function() {

      var links = this.get('_links');
      if (!links) {
        throw new Error('Resource has no _links property.');
      }

      return links.link.apply(links, Array.prototype.slice.call(arguments));
    },
    
    hasLink: function(rel) {
      return this.has('_links') && this.get('_links').has(rel);
    },

    embedded: function(rel) {
      var embedded = this.get('_embedded');
      return embedded ? embedded.embedded.apply(embedded, Array.prototype.slice.call(arguments)) : null;
    },

    hasEmbedded: function(rel) {
      return this.has('_embedded') && this.get('_embedded').has(rel);
    },

    hasSameUri: function(other) {
      if (!other) {
        return false;
      }

      return this.link('self').get('href') == other.link('self').get('href');
    },

    isNew: function() {
      return !this.hasLink('self')
    }
  });

  var halModelExtend = HalModel.extend;

  HalModel.extend = function(options) {

    options = _.defaults({}, options, {
      relations: [],
      halLinks: [],
      halEmbedded: []
    });

    var links = HalModelLinks.extend({

      relations: _.map(options.halLinks, function(halLink) {
        return _.defaults({}, _.isObject(halLink) ? halLink : { key: halLink }, {
          type: Backbone.HasOne,
          relatedModel: HalLink
        });
      })
    });

    var embedded = HalModelEmbedded.extend({

      relations: _.map(options.halEmbedded, function(halEmbedded) {
        return _.clone(halEmbedded);
      })
    });

    options.relations.push({
      type: Backbone.HasOne,
      key: '_links',
      relatedModel: links,
      includeInJSON: false
    });

    options.relations.push({
      type: Backbone.HasOne,
      key: '_embedded',
      relatedModel: embedded,
      includeInJSON: false
    });

    return halModelExtend.call(HalModel, options);
  };

  var HalCollection = this.HalCollection = Backbone.Collection.extend({

    // TODO: HalCollection should get its URL from API root through relations

    parse: function(response, options) {
      return response['_embedded'] ? response['_embedded'][this.embeddedModels] || [] : [];
    }
  });
});

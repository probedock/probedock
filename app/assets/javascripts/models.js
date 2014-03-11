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

  this.ApiRoot = Backbone.RelationalHalResource.extend({
    defaults: function() {
      return {
        _links: {
          self: {
            href: Path.build('api')
          }
        }
      };
    }
  });

  this.addInitializer(function() {
    App.apiRoot = new App.models.ApiRoot();
  });

  // FIXME: remove HalModel once replaced by HalResource
  this.HalModel = Backbone.RelationalHalResource;
  this.HalResource = Backbone.RelationalHalResource;

  this.defineHalCollection = function(model, options) {
    return this.HalResource.extend(_.extend({
      
      halEmbedded: [
        {
          type: Backbone.HasMany,
          key: 'item',
          relatedModel: model,
          reset: true // FIXME: see backbone-relational.js
        }
      ],

      defaults: {
        _embedded: {
          'item': []
        }
      }
    }, options));
  };
});

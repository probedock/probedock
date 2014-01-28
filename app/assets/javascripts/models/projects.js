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

  var Project = this.Project = Backbone.RelationalModel.extend({

    idAttribute: 'apiId',
    relations: [
      {
        type: Backbone.HasMany,
        key: 'testKeys',
        relatedModel: 'TestKey',
        collectionType: 'TestKeyCollection'
      }
    ],

    url: function() {
      return this.isNew() ? ApiPath.build('projects') : ApiPath.build('projects', this.get('apiId'));
    },

    path: function() {
      return Path.build('projects', this.get('urlToken'));
    },

    link: function(options) {
      options = _.defaults({}, options, { truncate: false });
      return $('<a />').attr('href', this.path()).text(Format.truncate(this.get('name'), options.truncate));
    }
  });

  var ProjectCollection = this.ProjectCollection = Backbone.Collection.extend({
    model: Project
  });

  var ProjectTableCollection = this.ProjectTableCollection = this.HalCollection.extend({

    url: ApiPath.builder('projects'),
    model: Project,
    embeddedModels: 'v1:projects'
  });
});

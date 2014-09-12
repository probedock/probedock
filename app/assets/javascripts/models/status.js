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

  var AppStatusData = Backbone.RelationalModel.extend({

    uptime: function() {
      return new Date().getTime() - this.get('startedAt');
    }
  });

  var JobsStatusData = Backbone.RelationalModel.extend({
  });

  var CountStatusData = Backbone.RelationalModel.extend({
  });

  var TestsStatusData = Backbone.RelationalModel.extend({
  });

  var DbStatusData = Backbone.RelationalModel.extend({
  });

  this.GeneralStatusData = Backbone.RelationalModel.extend({

    url: Path.builder('data', 'general'),
    relations: [
      {
        type: Backbone.HasOne,
        key: 'app',
        relatedModel: AppStatusData
      },
      {
        type: Backbone.HasOne,
        key: 'jobs',
        relatedModel: JobsStatusData
      },
      {
        type: Backbone.HasOne,
        key: 'count',
        relatedModel: CountStatusData
      },
      {
        type: Backbone.HasOne,
        key: 'db',
        relatedModel: DbStatusData
      },
      {
        type: Backbone.HasOne,
        key: 'tests',
        relatedModel: TestsStatusData
      }
    ]
  });
});

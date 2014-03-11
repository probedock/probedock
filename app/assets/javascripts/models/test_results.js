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

  this.TestResult = this.HalModel.extend({

    halEmbedded: [
      {
        type: Backbone.HasOne,
        key: 'v1:runner',
        relatedModel: 'User'
      },
      {
        type: Backbone.HasOne,
        key: 'v1:testRun',
        relatedModel: 'TestRun'
      },
      {
        type: Backbone.HasOne,
        key: 'v1:test',
        relatedModel: 'Test'
      }
    ],

    status: function() {
      if (!this.get('active')) {
        return 'inactive';
      } else {
        return this.get('passed') ? 'passed' : 'failed';
      }
    }
  });

  this.TestResults = this.defineHalCollection(this.TestResult, {});
});

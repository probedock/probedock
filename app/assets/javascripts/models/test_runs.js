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

  var TestRun = this.TestRun = this.HalModel.extend({

    halLinks: [ 'self', 'alternate' ],
    halEmbedded: [
      {
        type: Backbone.HasOne,
        key: 'v1:runner',
        relatedModel: 'User'
      }
    ],

    counts: function() {
      return {
        passed: this.passedCount(),
        failed: this.failedCount(),
        inactive: this.inactiveCount()
      };
    },

    percentages: function(precision) {

      var multiplier = Math.pow(10, precision || 2);

      var passed = Math.round(this.passedCount() * 100 * multiplier / this.totalCount());

      var inactive = Math.round(this.inactiveCount() * 100 * multiplier / this.totalCount());
      if (passed + inactive > 100 * multiplier) {
        inactive = 100 * multiplier - passed;
      }

      var failed = 100 * multiplier - passed - inactive;

      return {
        passed: passed / multiplier,
        inactive: inactive / multiplier,
        failed: failed / multiplier
      };
    },

    passedCount: function(includeInactive) {
      return this.get('passedResults') - (includeInactive ? 0 : this.get('inactivePassedResults'));
    },

    failedCount: function(includeInactive) {
      return this.get('results') - this.get('passedResults') - (includeInactive ? 0 : this.get('inactiveResults') - this.get('inactivePassedResults'));
    },

    inactiveCount: function() {
      return this.get('inactiveResults');
    },

    passedAndInactiveCount: function() {
      return this.get('passedResults') + this.get('inactiveResults') - this.get('inactivePassedResults');
    },

    totalCount: function() {
      return this.get('results');
    },

    successDescription: function() {
      return _.reduce(this.counts(), function(memo, value, type) {
        return value ? memo.concat(Format.number(value) + ' ' + I18n.t('jst.testResult.status.' + type)) : memo;
      }, []).join(', ');
    }
  });

  var TestRunCollection = this.TestRunCollection = this.HalCollection.extend({

    model: TestRun,
    embeddedModels: 'v1:test-runs',
    halUrl: [ { rel: 'v1:test-runs', template: {} } ]
  });
});

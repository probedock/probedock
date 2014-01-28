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
App.module('views', function() {

  var TestRunHealthBar = this.TestRunHealthBar = Marionette.ItemView.extend({

    tagName: 'a',
    className: 'progress',
    template: 'testRunHealthBar',

    ui: {
      passedBar: '.progress-bar-success',
      inactiveBar: '.progress-bar-warning',
      failedBar: '.progress-bar-danger'
    },

    onRender: function() {

      this.$el.attr('href', this.model.path());

      var counts = this.model.counts(),
          percentages = this.model.percentages();

      _.each([ 'passed', 'inactive', 'failed' ], function(type) {

        var percentage = percentages[type];

        var bar = this.ui[type + 'Bar'];
        bar[percentage ? 'show' : 'hide']();

        if (percentage) {
          bar.css('width', percentage + '%');
          if (percentage >= 15) {
            bar.text(Format.number(counts[type]));
          } else {
            bar.empty();
          }
        }
      }, this);

      this.$el.tooltip({
        title: this.model.successDescription()
      });
    }
  });
});

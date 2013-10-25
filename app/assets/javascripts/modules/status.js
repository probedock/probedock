// Copyright (c) 2012-2013 Lotaris SA
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

App.autoModule('status', function() {

  var Status = Backbone.Model.extend({

    url: Path.builder('data', 'status'),

    initialize: function() {
      this.numberOfErrors = 0;
      this.on('change', this.notifyChanges, this);
    },

    notifyChanges: function() {
      App.debug('App status has changed: ' + _.keys(this.changedAttributes()).join(', ') + ' (' + new Date() + ')');
      App.vent.trigger('statusChanged', this.changedAttributes());
    },

    watch: function() {
      App.debug('Checking app status every ' + App.pollingFrequency + 'ms');
      this.refreshPeriodically();
    },

    refreshPeriodically: function(resetErrors) {
      if (resetErrors) {
        this.numberOfErrors = 0;
      }
      setTimeout(_.bind(this.refresh, this), App.pollingFrequency);
    },

    refresh: function() {
      this.fetch().done(_.bind(this.refreshPeriodically, this, true)).fail(_.bind(this.countError, this));
    },

    countError: function() {
      this.numberOfErrors += 1;
      if (this.numberOfErrors >= 3) {
        this.showError();
      } else {
        this.refreshPeriodically();
      }
    },

    showError: function() {
      Alerts.warning('jst.statusModule.disconnected').prependTo($('body .page-container')).hide().fadeIn('normal', function() {
        $(this).addClass('fade in');
      });
    }
  });
  
  this.addAutoInitializer(function(options) {
    new Status(options.config).watch();
  });
});

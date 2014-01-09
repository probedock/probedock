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
App.module('status', function() {

  var Status = Backbone.Model.extend({

    url: Path.builder('data', 'status'),

    initialize: function() {

      this.watch = false;
      this.maintenance = false;
      this.refreshing = false;
      this.numberOfErrors = 0;

      this.listenToOnce(this, 'change', this.startNotifyingChanges);
      this.listenTo(this, 'change:maintenance', this.notifyMaintenance);

      this.listenTo(App.vent, 'status:watch', this.startWatching);
      this.listenTo(App.vent, 'ajax:maintenance', this.startWatchingForMaintenance);
      this.listenTo(App.vent, 'maintenance:off', this.stopWatchingForMaintenance);
    },

    getMaintenanceData: function() {
      return this.get('maintenance') ? { since: this.get('maintenance') } : false;
    },

    notifyMaintenance: function(changed) {
      App.setMaintenance(this.getMaintenanceData());
    },

    startNotifyingChanges: function() {
      this.listenTo(this, 'change', this.notifyChanges);
    },

    notifyChanges: function() {
      App.debug('App status has changed: ' + _.keys(this.changedAttributes()).join(', ') + ' (' + new Date() + ')');
      App.vent.trigger('status:changed', this.changedAttributes());
    },

    startWatching: function() {
      this.watch = true;
      this.startRefreshing();
    },

    startWatchingForMaintenance: function() {
      this.maintenance = true;
      this.startRefreshing();
    },

    stopWatchingForMaintenance: function() {
      this.maintenance = false;
      if (!this.watch && this.timeout) {
        clearTimeout(this.timeout);
        App.debug('Stopped checking app status for maintenance');
      }
    },

    startRefreshing: function() {
      if (!this.refreshing) {
        this.refreshing = true;
        App.debug('Checking app status every ' + App.pollingFrequency + 'ms');
        this.refreshPeriodically();
      }
    },

    refreshPeriodically: function(resetErrors) {

      if (resetErrors) {
        this.numberOfErrors = 0;
      }

      if (this.watch || this.maintenance) {
        this.timeout = setTimeout(_.bind(this.refresh, this), App.pollingFrequency);
      }
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
      App.vent.trigger('flash', { type: 'warning', message: I18n.t('jst.statusModule.disconnected') });
    }
  });
  
  this.addInitializer(function() {

    var status = new Status();
    
    var initialData = $('body').data('status');
    if (initialData) {
      status.set(initialData);
    }
  });
});

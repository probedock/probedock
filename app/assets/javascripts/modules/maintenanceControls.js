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
App.autoModule('maintenanceControls', function() {

  var MaintenanceControls = Marionette.ItemView.extend({

    className: 'panel panel-primary maintenanceControls',
    template: 'maintenanceControls/view',

    ui: {
      controlButton: '.toggle',
      statusLabel: '.label',
      time: '.time'
    },

    events: {
      'click .toggle': 'toggleMaintenance'
    },

    appEvents: {
      'maintenance:changed': 'updateState'
    },

    initialize: function() {
      App.bindEvents(this);
      setInterval(_.bind(this.updateTime, this), 1000);
    },

    onRender: function() {
      this.updateState();
    },

    toggleMaintenance: function() {
      this[App.maintenance ? 'stopMaintenance' : 'startMaintenance']();
    },

    startMaintenance: function() {
      if (confirm(I18n.t('jst.maintenanceControls.confirmation'))) {
        this.requestMaintenance(true);
      }
    },

    stopMaintenance: function() {
      this.requestMaintenance(false);
    },

    requestMaintenance: function(enabled) {
      this.setBusy(true);
      this.showError(false);

      $.ajax({
        url: Path.build('maintenance'),
        type: enabled ? 'POST' : 'DELETE'
      }).done(_.bind(this.applyMaintenance, this, enabled)).fail(_.bind(this.showError, this)).always(_.bind(this.setBusy, this, false));
    },

    showError: function(xhr) {
      if (xhr === false) {
        this.ui.controlButton.nextAll('.alert').remove();
      } else if (xhr.status != 503) {
        Alerts.danger({ message: I18n.t('jst.maintenanceControls.error'), fade: true }).insertAfter(this.ui.controlButton);
      }
    },

    applyMaintenance: function(enabled, response, textStatus, xhr) {
      if (enabled ? xhr.getResponseHeader('Content-Type').match(/^application\/json/) : xhr.status == 204) {
        App.setMaintenance(enabled ? response : undefined);
      }
    },

    setBusy: function(busy) {
      this.busy = busy;
      this.updateControls();
    },

    updateControls: function() {
      this.ui.controlButton.attr('disabled', !!this.busy);
    },

    updateState: function() {

      this.updateTime();
      this.updateControls();

      this.$el.removeClass('panel-primary panel-danger').addClass('panel-' + (App.maintenance ? 'danger' : 'primary'));

      this.ui.statusLabel.removeClass('label-success label-danger').addClass('label-' + (App.maintenance ? 'danger' : 'success'));
      this.ui.statusLabel.text(I18n.t('jst.maintenanceControls.status' + (App.maintenance ? 'On' : 'Off')));

      this.ui.controlButton.removeClass('btn-warning btn-primary').addClass('btn-' + (App.maintenance ? 'primary' : 'warning'));
      this.ui.controlButton.text(I18n.t('jst.maintenanceControls.' + (App.maintenance ? 'deactivate' : 'activate')));
    },

    updateTime: function() {
      if (App.maintenance) {
        this.ui.time.text(Format.duration(new Date().getTime() - App.maintenance.since, { min: 's', shorten: 'm' }));
      } else {
        this.ui.time.text(I18n.t('jst.common.noData'));
      }
    }
  });

  this.addAutoInitializer(function(options) {
    options.region.show(new MaintenanceControls());
  });
});

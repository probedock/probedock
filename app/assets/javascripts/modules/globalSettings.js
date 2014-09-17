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
App.autoModule('globalSettings', function() {

  var Settings = Backbone.Model.extend({
    url: LegacyApiPath.builder('settings')
  });

  var SettingsForm = Marionette.ItemView.extend({

    template: 'globalSettings',
    ui: {
      ticketingSystemUrl: '#settings_ticketing_system_url',
      reportsCacheSize: '#settings_reports_cache_size',
      tagCloudSize: '#settings_tag_cloud_size',
      testOutdatedDays: '#settings_test_outdated_days',
      testPayloadsLifespan: '#settings_test_payloads_lifespan',
      testRunsLifespan: '#settings_test_runs_lifespan',
      fields: 'form :input',
      saveButton: 'form button',
      formControls: 'form .form-controls'
    },

    events: {
      'submit form': 'save'
    },

    modelEvents: {
      'change': 'refresh'
    },

    appEvents: {
      'maintenance:changed': 'updateControls'
    },

    model: new Settings(),

    initialize: function() {
      App.bindEvents(this);
    },

    onRender: function() {
      this.$el.button();
      this.model.fetch(this.requestOptions());
      this.updateControls();
    },

    setBusy: function(busy) {
      this.busy = busy;
      this.updateControls();
    },

    updateControls: function() {
      this.ui.saveButton.attr('disabled', this.busy || !!App.maintenance);
      this.ui.fields.attr('disabled', !!App.maintenance);
    },

    refresh: function() {
      this.ui.ticketingSystemUrl.val(this.model.get('ticketing_system_url'));
      this.ui.reportsCacheSize.val(this.model.get('reports_cache_size'));
      this.ui.tagCloudSize.val(this.model.get('tag_cloud_size'));
      this.ui.testOutdatedDays.val(this.model.get('test_outdated_days'));
      this.ui.testPayloadsLifespan.val(this.model.get('test_payloads_lifespan'));
      this.ui.testRunsLifespan.val(this.model.get('test_runs_lifespan'));
    },

    save: function(e) {
      e.preventDefault();

      this.setNotice(false);
      this.setBusy(true);

      var options = this.requestOptions();
      options.type = 'PUT';
      options.success = _.bind(this.onSaved, this, 'success');
      options.error = _.bind(this.onSaved, this, 'error');

      this.model.save({
        ticketing_system_url: this.ui.ticketingSystemUrl.val(),
        reports_cache_size: this.ui.reportsCacheSize.val(),
        tag_cloud_size: this.ui.tagCloudSize.val(),
        test_outdated_days: this.ui.testOutdatedDays.val(),
        test_payloads_lifespan: this.ui.testPayloadsLifespan.val(),
        test_runs_lifespan: this.ui.testRunsLifespan.val()
      }, options).always(_.bind(this.setBusy, this, false));
    },

    onSaved: function(result) {
      this.setNotice(result);
      if (result == 'success') {
        this.refresh();
      }
    },

    setNotice: function(type) {
      this.ui.saveButton.next('.text-success,.text-danger').remove();
      if (type == 'success') {
        $('<span class="text-success" />').text(I18n.t('jst.globalSettings.success')).insertAfter(this.ui.saveButton).hide().fadeIn('fast');
      } else if (type == 'error') {
        $('<span class="text-danger" />').text(I18n.t('jst.globalSettings.error')).insertAfter(this.ui.saveButton).hide().fadeIn('fast');
      }
    },

    requestOptions: function() {
      return {
        dataType: 'json',
        accepts: {
          json: 'application/json'
        }
      };
    }
  });

  this.addAutoInitializer(function(options) {
    options.region.show(new SettingsForm());
  });
});

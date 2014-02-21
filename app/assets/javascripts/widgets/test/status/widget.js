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
(function() {

  App.addTestWidget('status', Marionette.ItemView, {

    statusClass: {
      passed: 'success',
      failed: 'danger',
      inactive: 'warning',
      deprecated: 'default'
    },

    ui: {
      statusDescription: '.description .status',
      inactiveDescription: '.description .inactive',
      deprecatedDescription: '.description .deprecated',
      deprecateButton: '.deprecate',
      controls: '.btn-group'
    },

    events: {
      'click .deprecate': 'toggleDeprecation'
    },

    appEvents: {
      'maintenance:changed': 'updateControls'
    },

    modelEvents: {
      'change:deprecatedAt': 'updateStatus'
    },

    initializeWidget: function() {
      App.bindEvents(this);
    },

    onRender: function() {
      this.renderDescription();
      this.updateStatus();
    },

    toggleDeprecation: function() {

      var deprecate = !this.model.isDeprecated();
      if (!confirm(this.t(deprecate ? 'deprecateConfirmation' : 'undeprecateConfirmation'))) {
        return;
      }

      this.ui.controls.next('.text-warning').remove();
      this.setBusy(true);

      $.ajax({
        url: this.model.link('v1:deprecation').get('href'),
        type: deprecate ? 'PUT' : 'DELETE',
        dataType: 'json'
      }).always(_.bind(this.setBusy, this, false)).done(_.bind(this.setDeprecated, this, deprecate)).fail(_.bind(this.showDeprecationError, this));
    },

    setDeprecated: function(deprecate, response) {
      this.model.setDeprecated(deprecate, response ? response.createdAt : undefined);
    },

    showDeprecationError: function() {
      $('<p class="text-warning" />').text(this.t('deprecationError')).insertAfter(this.ui.controls).hide().slideDown();
    },

    updateControls: function() {

      this.ui.deprecateButton.attr('disabled', this.busy || App.maintenance);

      var deprecated = this.model.isDeprecated();
      this.ui.deprecateButton.text(this.t(deprecated ? 'undeprecate' : 'deprecate'));
      this.ui.deprecateButton.removeClass('btn-default btn-warning').addClass(deprecated ? 'btn-default' : 'btn-warning');
    },

    setBusy: function(busy) {
      this.busy = busy;
      this.updateControls();
    },

    renderDescription: function() {

      var passing = this.model.get('passing')

      this.ui.statusDescription.html(this.t('statusDescription.' + (passing ? 'passed' : 'failed')));
      this.ui.statusDescription.find('strong').removeClass('passed failed').addClass(passing ? 'text-success' : 'text-danger');

      this.ui.inactiveDescription.html(this.t('inactiveDescription'));
      this.ui.inactiveDescription.find('strong').addClass('text-warning');

      this.ui.deprecatedDescription.html(this.t('deprecatedDescription'));
    },

    updateStatus: function() {
      var status = this.model.status();
      this.ui.inactiveDescription[status == 'inactive' ? 'show' : 'hide']();
      this.ui.deprecatedDescription[status == 'deprecated' ? 'show' : 'hide']();
      this.trigger('widget:status', this.statusClass[this.model.status()]);
      this.updateControls();
    }
  });
})();

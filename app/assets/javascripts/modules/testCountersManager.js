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
App.autoModule('testCountersManager', function() {

  var TestCountersData = Backbone.Model.extend({

    url: Path.builder('data', 'test_counters'),
    
    status: function() {
      if (this.get('preparing')) {
        return 'preparing';
      } else if (this.get('recomputing') || this.get('jobs') || this.get('remainingResults')) {
        return 'computing';
      } else {
        return 'idle';
      }
    }
  });

  var Manager = Backbone.Marionette.ItemView.extend({

    className: 'panel testCountersManager',
    template: 'testCountersManager',

    ui: {
      statusLabel: 'tbody .label',
      recomputeButton: '.panel-footer .recompute',
      dataRows: 'tbody tr',
      jobs: 'tbody td.jobs',
      remainingResults: 'tbody td.remainingResults',
      totalCounters: 'tbody td.totalCounters',
      instructions: '.panel-body .instructions',
      maintenanceNotice: 'p.maintenance',
      startedNotice: 'p.started',
      title: '.panel-heading .panel-title'
    },

    events: {
      'click .recompute': 'recompute'
    },
    modelEvents: {
      'change': 'updateState'
    },

    initialize: function() {
      this.listenTo(App.vent, 'maintenance:changed', this.updateState);
    },

    onRender: function() {
      this.updateState();
      App.watchStatus(this, this.refresh, { only: [ 'counters', 'lastTestCounters' ] });
    },

    updateState: function() {

      var status = this.model.status();

      this.$el.removeClass('panel-default panel-primary').addClass('panel-' + (App.maintenance || status != 'idle' ? 'primary' : 'default'));

      this.ui.maintenanceNotice[App.maintenance ? 'hide' : 'show']();
      this.ui.startedNotice[App.maintenance && status == 'computing' ? 'show' : 'hide']();

      this.ui.title.removeClass('disabled');
      this.ui.instructions.removeClass('text-muted');
      if (!App.maintenance && status == 'idle') {
        this.ui.title.addClass('disabled');
        this.ui.instructions.addClass('text-muted');
      }

      this.renderModel();
    },

    renderModel: function() {
      this.renderStatus();
      this.updateControls();
      this.ui.jobs.text(Format.number(this.model.get('jobs')));
      this.ui.remainingResults.text(Format.number(this.model.get('remainingResults')));
      this.ui.totalCounters.text(Format.number(this.model.get('totalCounters')));
    },

    renderStatus: function() {

      this.ui.dataRows.removeClass('warning');
      this.ui.statusLabel.removeClass('label-default label-warning');

      var status = this.model.status();

      if (status != 'idle') {
        this.ui.dataRows.addClass('warning');
        this.ui.statusLabel.addClass('label-warning');
      } else {
        this.ui.statusLabel.addClass('label-default');
      }

      this.ui.statusLabel.text(I18n.t('jst.testCountersManager.statuses.' + status));
    },

    updateControls: function() {
      var status = this.model.status();
      this.ui.recomputeButton.removeClass('btn-warning btn-default').addClass('btn-' + (App.maintenance ? 'warning' : 'default'));
      this.ui.recomputeButton.attr('disabled', !App.maintenance || status != 'idle');
    },

    refresh: function() {
      this.model.fetch();
    },

    recompute: function() {
      if (!confirm(I18n.t('jst.testCountersManager.recomputeConfirmation'))) {
        return;
      }
      this.ui.recomputeButton.attr('disabled', true);
      this.model.save({ recomputing: true, preparing: true });
    }
  });

  this.addAutoInitializer(function(options) {
    options.region.show(new Manager({ model: new TestCountersData(options.config.data) }));
  });
});

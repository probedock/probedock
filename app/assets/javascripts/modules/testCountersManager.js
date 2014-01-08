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
App.autoModule('testCountersManager', function() {

  var TestCountersData = Backbone.Model.extend({

    url: Path.builder('data', 'test_counters'),
    
    status: function() {
      return this.get('recomputing') || this.get('jobs') || this.get('remainingResults') ? 'computing' : 'idle';
    }
  });

  var Manager = Backbone.Marionette.ItemView.extend({

    tagName: 'div',
    className: 'panel panel-default testCountersManager',
    template: 'testCountersManager',
    ui: {
      statusLabel: 'tbody .label',
      recomputeButton: 'tfoot .recompute',
      dataRows: 'tbody tr',
      jobs: 'tbody td.jobs',
      remainingResults: 'tbody td.remainingResults',
      totalCounters: 'tbody td.totalCounters'
    },

    events: {
      'click .recompute': 'recompute'
    },
    modelEvents: {
      'change': 'renderModel'
    },

    onRender: function() {
      this.renderModel();
      App.watchStatus(this, this.refresh, { only: [ 'counters', 'lastTestCounters' ] });
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

      if (status == 'computing') {
        this.ui.dataRows.addClass('warning');
        this.ui.statusLabel.addClass('label-warning');
      } else {
        this.ui.statusLabel.addClass('label-default');
      }

      this.ui.statusLabel.text(I18n.t('jst.testCountersManager.statuses.' + status));
    },

    updateControls: function() {
      this.ui.recomputeButton.attr('disabled', this.model.status() == 'computing');
    },

    refresh: function() {
      this.model.fetch();
    },

    recompute: function() {
      if (!confirm(I18n.t('jst.testCountersManager.recomputeConfirmation'))) {
        return;
      }
      this.ui.recomputeButton.attr('disabled', true);
      this.model.save({ recomputing: true });
    }
  });

  this.addAutoInitializer(function(options) {
    options.region.show(new Manager({ model: new TestCountersData(options.config.data) }));
  });
});

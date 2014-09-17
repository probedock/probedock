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
App.autoModule('purge', function() {

  var PurgeRow = Marionette.ItemView.extend({
    
    template: 'purge/purge',
    tagName: 'tr',

    ui: {
      description: '.description'
    },

    modelEvents: {
      'change': 'renderDescription'
    },

    renderDescription: function() {
      this.ui.description.text(this.purgeDescription());
    },

    serializeData: function() {
      return _.extend(this.model.toJSON(), {
        name: this.model.name(),
        description: this.purgeDescription()
      });
    },

    purgeDescription: function() {
      if (this.model.get('dataLifespan')) {
        return I18n.t('jst.purge.description.outdated', {
          n: this.model.get('numberRemaining') ? Format.number(this.model.get('numberRemaining')) : I18n.t('jst.purge.none'),
          lifespan: Format.duration(this.model.get('dataLifespan') * 24 * 3600 * 1000)
        });
      } else {
        return I18n.t('jst.purge.description.orphan', {
          n: this.model.get('numberRemaining') || I18n.t('jst.purge.none')
        });
      }
    }
  });

  var Layout = Marionette.CompositeView.extend({

    template: 'purge/layout',
    className: 'purgeControls panel panel-primary',
    childView: PurgeRow,
    childViewContainer: 'tbody',

    ui: {
      settingsLink: 'a.settingsLink',
      purgeSelect: '.purgeTarget',
      purgeButton: '.purge',
      controls: '.panel-footer',
      jobsRow: 'tfoot tr.jobs',
      jobs: 'tfoot td'
    },

    events: {
      'submit form': 'purge',
      'change .purgeTarget': 'updateControls'
    },

    modelEvents: {
      'change': 'renderJobs'
    },

    collectionEvents: {
      'change': 'updateControls'
    },

    appEvents: {
      'maintenance:changed': 'updateControls'
    },

    initialize: function() {
      this.collection = this.model.embedded('item');
    },

    onRender: function() {

      this.renderLinks();
      this.updateControls();

      App.bindEvents(this);
      App.watchStatus(this, this.refresh, { only: 'lastPurge' });

      this.setLoading(true);
      this.refresh().done(_.bind(this.setLoading, this, false)).done(_.bind(this.renderSelect, this));
    },

    onRefreshed: function() {
      this.renderJobs();
      this.renderJobsRow();
      this.updateControls();
    },

    purge: function(e) {
      e.preventDefault();

      var purge = this.selectedPurge();
      if (!confirm(I18n.t('jst.purge.confirm', { name: purge.name() }))) {
        return;
      }

      this.setBusy(true);

      var newPurge = new App.models.Purge({
        dataType: purge.get('dataType')
      });

      purge.save().done(_.bind(this.refresh, this)).fail(_.bind(this.setBusy, this, false));

      purge.once('change', function() {
        console.log('purge changed');
      });
      purge.once('change', _.bind(this.setBusy, this, false));
    },

    setBusy: function(busy) {
      this.busy = busy;
      this.updateControls();
    },

    setLoading: function(loading) {
      if (loading) {
        this.ui.jobs.html($('<em class="text-muted" />').text(I18n.t('jst.common.loading')));
      } else {
        this.ui.jobs.find('em').remove();
      }
    },

    renderJobs: function() {
      this.ui.jobs.text(Format.number(this.model.get('jobs')));
    },

    updateControls: function() {
      this.ui.purgeButton.attr('disabled', !!this.busy || !!App.maintenance || !this.selectedPurge().isPurgeable() || !!this.model.get('jobs'));
    },

    selectedPurge: function() {
      return this.collection.findWhere({ dataType: this.ui.purgeSelect.val() }) || this.model;
    },

    refresh: function() {
      if (this.refreshing) {
        return;
      }
      this.refreshing = true;

      var promise = this.model.fetch({
        data: {
          info: true
        }
      });
      
      promise.always(_.bind(function() {
        this.refreshing = false;
        this.triggerMethod('refreshed');
      }, this));

      return promise;
    },

    renderLinks: function() {
      this.ui.settingsLink.attr('href', Path.build('admin', 'settings'));
    },

    renderSelect: function() {
      this.collection.forEach(function(purge) {
        $('<option />').val(purge.get('dataType')).text(purge.name()).appendTo(this.ui.purgeSelect);
      }, this);
      this.updateControls();
    },

    renderJobsRow: function() {
      if (!!this.model.get('jobs')) {
        this.ui.jobsRow.addClass('warning');
      } else {
        this.ui.jobsRow.removeClass('warning');
      }
    }
  });

  this.addAutoInitializer(function(options) {
    options.region.show(new Layout({ model: new App.models.Purges() }));
  });
});

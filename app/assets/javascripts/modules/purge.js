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

  var Purge = Backbone.RelationalModel.extend({

    name: function() {
      return I18n.t('jst.purge.info.' + this.id + '.name');
    },

    isPurgeable: function() {
      return !!this.get('total');
    }
  });

  var PurgeCollection = Backbone.Collection.extend({

    url: Path.builder('purges'),
    model: Purge,

    isPurgeable: function() {
      return this.some(function(purge) {
        return purge.isPurgeable();
      });
    }
  });

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
      if (this.model.has('lifespan')) {
        return I18n.t('jst.purge.description.outdated', {
          n: this.model.get('total') || I18n.t('jst.purge.none'),
          lifespan: Format.duration(this.model.get('lifespan'))
        });
      } else {
        return I18n.t('jst.purge.description.orphan', {
          n: this.model.get('total') || I18n.t('jst.purge.none')
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
      controls: '.panel-footer'
    },

    events: {
      'submit form': 'purge',
      'change .purgeTarget': 'updateControls'
    },

    collectionEvents: {
      'change': 'updateControls'
    },

    appEvents: {
      'maintenance:changed': 'updateControls'
    },

    onRender: function() {

      this.renderLinks();
      this.renderSelect();
      this.updateControls();

      App.bindEvents(this);
      App.watchStatus(this, this.refresh, { only: 'lastPurge' });
    },

    purge: function(e) {
      e.preventDefault();

      var purge = this.selectedPurge();
      if (!confirm(I18n.t('jst.purge.confirm', {
        name: _.isFunction(purge.name) ? purge.name() : I18n.t('jst.purge.all')
      }))) {
        return;
      }

      this.setBusy(true);

      $.ajax({
        url: purge.url(),
        type: 'POST'
      }).fail(_.bind(this.setBusy, this, false));

      purge.once('change', _.bind(this.setBusy, this, false));
    },

    setBusy: function(busy) {
      this.busy = busy;

      if (busy && !this.ui.controls.find('.text-info').length) {
        $('<p class="text-info" />').text(I18n.t('jst.purge.purging')).appendTo(this.ui.controls).hide().slideDown();
      } else {
        this.ui.controls.find('.text-info').slideUp('fast', function() {
          $(this).remove();
        });
      }

      this.updateControls();
    },

    updateControls: function() {
      this.ui.purgeButton.attr('disabled', this.busy || App.maintenance || !this.selectedPurge().isPurgeable());
    },

    selectedPurge: function() {
      return this.collection.findWhere({ id: this.ui.purgeSelect.val() }) || this.collection;
    },

    refresh: function() {
      if (this.refreshing) {
        return;
      }
      this.refreshing = true;

      this.collection.fetch().always(_.bind(function() {
        this.refreshing = false;
      }, this));
    },

    renderLinks: function() {
      this.ui.settingsLink.attr('href', Path.build('admin', 'settings'));
    },

    renderSelect: function() {
      this.collection.forEach(function(purge) {
        $('<option />').val(purge.id).text(purge.name()).appendTo(this.ui.purgeSelect);
      }, this);
    }
  });

  this.addAutoInitializer(function(options) {
    options.region.show(new Layout({ collection: new PurgeCollection(options.config) }));
  });
});

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
App.autoModule('purgesTable', function() {

  var NoPurgeRow = Marionette.ItemView.extend({

    tagName: 'tr',
    className: 'empty',
    template: function() {
      return _.template('<td colspan="4"><%- empty %></td>', { empty: I18n.t('jst.purgesTable.empty') })
    }
  });

  var PurgeRow = Marionette.ItemView.extend({
    
    tagName: 'tr',
    template: 'purgesTable/row',

    ui: {
      dataType: '.dataType',
      numberPurged: '.numberPurged',
      createdAt: '.createdAt',
      duration: '.duration'
    },

    onRender: function() {
      this.ui.dataType.text(I18n.t('jst.purge.info.' + this.model.get('dataType') + '.name'));
      this.ui.numberPurged.text(Format.number(this.model.get('numberPurged')));
      this.ui.createdAt.text(Format.datetime.long(new Date(this.model.get('createdAt'))));
      this.renderDuration();
    },

    renderDuration: function() {
      if (this.model.has('completedAt')) {
        this.ui.duration.text(Format.duration(this.model.get('completedAt') - this.model.get('createdAt')));
      } else {
        this.ui.duration.html($('<em class="text-muted" />').text(I18n.t('jst.purgesTable.inProgress')));
      }
    }
  });

  var PurgesTableView = Tableling.Bootstrap.TableView.extend({

    template: 'purgesTable/table',
    childView: PurgeRow,
    childViewContainer: 'tbody',
    emptyView: NoPurgeRow,
  });

  var PurgesTable = App.views.Table.extend({

    config: {
      pageSize: 15,
      sort: [ 'createdAt desc' ]
    },

    tableView: PurgesTableView,
    halEmbedded: 'item'
  });

  this.addAutoInitializer(function(options) {
    options.region.show(new PurgesTable({ model: new App.models.Purges() }));
  });
});

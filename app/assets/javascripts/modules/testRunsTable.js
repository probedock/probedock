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
App.autoModule('testRunsTable', function() {

  var NoTestRunRow = Marionette.ItemView.extend({

    tagName: 'tr',
    className: 'empty',
    template: function() {
      return _.template('<td colspan="5"><%- empty %></td>', { empty: I18n.t('jst.testRunsTable.empty') })
    }
  });

  var TestRunRow = Marionette.LayoutView.extend({
    
    tagName: 'tr',
    template: 'testRunsTable/row',

    regions: {
      runner: '.runner',
      status: '.status'
    },

    ui: {
      numberOfResults: '.numberOfResults',
      endedAt: '.endedAt',
      duration: '.duration',
      group: '.group'
    },

    onRender: function() {
      this.ui.endedAt.html(this.endedAtCell());
      this.ui.duration.text(Format.duration(this.model.get('duration')));
      this.renderGroup();
      this.runner.show(new App.views.UserAvatar({ model: this.model.embedded('v1:runner'), size: 'small' }));
      this.status.show(new App.views.TestRunHealthBar({ model: this.model }));
    },

    renderGroup: function() {
      if (this.model.get('group')) {
        var url = this.model.link('alternate').get('href') + '?' + $.param({ groups: [ this.model.get('group') ] });
        this.ui.group.html($('<a />').attr('href', url).text(this.model.get('group')));
      } else {
        this.ui.group.text(I18n.t('jst.common.noData'));
      }
    },

    endedAtCell: function() {
      var endedAt = Format.datetime.long(new Date(this.model.get('endedAt')));
      return $('<a />').attr('href', this.model.link('alternate').get('href')).text(endedAt);
    }
  });

  var TestRunsTableView = Tableling.Bootstrap.TableView.extend({

    template: 'testRunsTable/table',
    childView: TestRunRow,
    childViewContainer: 'tbody',
    emptyView: NoTestRunRow,
  });

  var TestRunsTable = App.views.TableWithAdvancedSearch.extend({

    advancedSearchTemplate: 'testRunsTable/search',
    ui: {
      groupsFilter: '.advancedSearch form .groups',
      runnersFilter: '.advancedSearch form .runners'
    },

    events: {
      'change .advancedSearch form .groups': 'updateSearch',
      'change .advancedSearch form .runners': 'updateSearch'
    },

    config: {
      sort: [ 'endedAt desc' ],
      pageSize: 15
    },

    tableView: TestRunsTableView,
    halEmbedded: 'item',

    wrapSearchData: false,

    searchFilters: [
      { name: 'groups' },
      {
        name: 'runners',
        optionText: function(runner) { return runner.name; },
        optionValue: function(runner) { return runner.name; },
        sort: function(a, b) { return a.name.localeCompare(b.name); }
      }
    ]
  });

  this.addAutoInitializer(function(options) {
    options.region.show(new TestRunsTable(_.extend(options.config, { model: new App.models.TestRuns() })));
  });
});

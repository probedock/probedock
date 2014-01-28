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

  var models = App.module('models');
  var TestRun = models.TestRun,
      TestRunCollection = models.TestRunCollection;

  var views = App.module('views');
  var TableWithAdvancedSearch = views.TableWithAdvancedSearch,
      UserAvatar = views.UserAvatar;

  var NoTestRunRow = Marionette.ItemView.extend({

    tagName : 'tr',
    className : 'empty',
    template : function() {
      return _.template('<td colspan="5"><%- empty %></td>', { empty : I18n.t('jst.testRunsTable.empty') })
    }
  });

  var TestRunRow = Marionette.ItemView.extend({
    
    tagName : 'tr',
    template : 'testRunsTable/row',

    ui : {
      runner : '.runner',
      status : '.status',
      numberOfResults : '.numberOfResults',
      endedAt : '.endedAt',
      duration : '.duration',
      group : '.group'
    },

    onRender : function() {
      this.ui.endedAt.html(this.endedAtCell());
      this.ui.status.html(this.statusCell());
      this.ui.numberOfResults.text(this.model.get('results_count'));
      this.ui.duration.text(Format.duration(this.model.get('duration')));
      this.renderGroup();
      this.renderRunner();
    },

    renderRunner : function() {
      new UserAvatar({ model : this.model.get('runner'), el : this.ui.runner, size : 'small' }).render();
    },

    renderGroup : function() {
      if (this.model.get('group')) {
        this.ui.group.html($('<a />').attr('href', Path.build('runs?' + $.param({ groups : [ this.model.get('group') ] }))).text(this.model.get('group')));
      } else {
        this.ui.group.text(I18n.t('jst.common.noData'));
      }
    },

    endedAtCell : function() {
      var endedAt = Format.datetime.long(new Date(this.model.get('ended_at')));
      return $('<a />').attr('href', this.model.path()).text(endedAt);
    },

    statusCell : function() {
      var el = $('<a />').attr('href', this.model.path()).text(this.model.humanSuccessRatio());
      el.css('color', this.model.successColor().toHexString());
      return el.tooltip({ title : this.model.successDescription() });
    }
  });

  var TestRunsTableView = Tableling.Bootstrap.TableView.extend({

    template : 'testRunsTable/table',
    itemView : TestRunRow,
    itemViewContainer : 'tbody',
    emptyView : NoTestRunRow,
  });

  var TestRunsTable = TableWithAdvancedSearch.extend({

    advancedSearchTemplate : 'testRunsTable/search',
    ui : {
      groupsFilter : '.advancedSearch form .groups',
      runnersFilter : '.advancedSearch form .runners'
    },

    events : {
      'change .advancedSearch form .groups' : 'updateSearch',
      'change .advancedSearch form .runners' : 'updateSearch'
    },

    config : {
      sort : [ 'ended_at desc' ],
      pageSize : 15
    },

    tableView : TestRunsTableView,
    tableViewOptions : {
      collection : new TestRunCollection()
    },

    searchFilters : [
      { name : 'groups' },
      {
        name : 'runners',
        optionText : function(runner) { return runner.name; },
        optionValue : function(runner) { return runner.name; },
        sort : function(a, b) { return a.name.localeCompare(b.name); }
      }
    ]
  });

  this.addAutoInitializer(function(options) {
    options.region.show(new TestRunsTable(options.config));
  });
});

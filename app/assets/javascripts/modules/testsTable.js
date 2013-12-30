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
App.autoModule('testsTable', function() {

  var models = App.module('models');
  var Test = models.Test,
      TestTableCollection = models.TestTableCollection;

  var views = App.module('views');
  var TableWithAdvancedSearch = views.TableWithAdvancedSearch,
      UserAvatar = views.UserAvatar;

  var NoTestRow = Backbone.Marionette.ItemView.extend({

    tagName: 'tr',
    className: 'empty',
    template : function() {
      return _.template('<td colspan="7"><%- empty %></td>', { empty : I18n.t('jst.testsTable.empty') });
    }
  });

  var TestRow = Backbone.Marionette.ItemView.extend({

    tagName : 'tr',
    template : 'testsTable/row',

    ui : {
      name : '.name',
      project : '.project',
      author : '.author',
      createdAt : '.createdAt',
      lastRunAt : '.lastRunAt',
      lastRunDuration : '.lastRunDuration',
      status : '.status'
    },

    onRender : function() {
      this.ui.name.html(this.model.link({ truncate : true }));
      this.ui.project.html(this.model.get('project').link());
      this.renderAuthor();
      this.ui.createdAt.text(Format.datetime.short(new Date(this.model.get('created_at'))));
      this.ui.lastRunAt.text(Format.datetime.short(new Date(this.model.get('last_run_at'))));
      this.ui.lastRunDuration.text(Format.duration(this.model.get('last_run_duration'), { format : 'short' }));
      this.renderStatus();
    },

    renderAuthor : function() {
      new UserAvatar({ model : this.model.get('author'), size : 'small', el : this.ui.author }).render();
    },

    renderStatus : function() {

      var badge;
      if (this.model.get('deprecated')) {
        badge = $('<span class="badge" />').text(I18n.t('jst.testsTable.status.deprecated'));
      } else if (!this.model.get('active')) {
        badge = $('<span class="badge badge-warning" />').text(I18n.t('jst.testsTable.status.inactive'));
      } else if (this.model.get('passing')) {
        badge = $('<span class="badge badge-success" />').text(I18n.t('jst.testsTable.status.passing'));
      } else {
        badge = $('<span class="badge badge-important" />').text(I18n.t('jst.testsTable.status.failing'));
      }

      badge.appendTo(this.ui.status).popover({
        html : true,
        trigger : 'click',
        title : this.tooltipTitle(),
        content : this.tooltipContents()
      }).tooltip({
        title : I18n.t('jst.testsTable.moreInfo')
      });
    },

    tooltipTitle : function() {

      var title = $('<strong />').text(I18n.t('jst.testsTable.' + (this.model.get('passing') ? 'lastRunner' : 'breaker')));
      if (!this.model.get('passing')) {
        title.addClass('breaker');
      }

      return title;
    },

    tooltipContents : function() {
      
      var wrapper = $('<div />');
      var effectiveResult = this.model.get('effective_result');
      var runner = effectiveResult.get('runner');

      var runnerEl = $('<div />').appendTo(wrapper);
      new UserAvatar({ model : runner, size : 'small', el : runnerEl }).render();

      var runLink = $('<a />').attr('href', PagePath.build('runs', effectiveResult.get('test_run_id'))).text('Go to test run');
      $('<p class="runLink" />').append(runLink).appendTo(wrapper);

      return wrapper;
    }
  });

  var TestsTableView = Tableling.Bootstrap.TableView.extend({

    template : 'testsTable/table',
    itemView : TestRow,
    itemViewContainer : 'tbody',
    emptyView : NoTestRow
  });

  var TestsTable = TableWithAdvancedSearch.extend({

    advancedSearchTemplate : 'testsTable/search',
    ui : {
      projectsFilter : '.advancedSearch form .projects',
      tagsFilter : '.advancedSearch form .tags',
      categoriesFilter : '.advancedSearch form .categories',
      authorsFilter : '.advancedSearch form .authors',
      breakersFilter : '.advancedSearch form .breakers',
      statusFilter : '.advancedSearch form .status'
    },

    events : {
      'change .advancedSearch form .status' : 'updateSearch',
      'change .advancedSearch form .projects' : 'updateSearch',
      'change .advancedSearch form .tags' : 'updateSearch',
      'change .advancedSearch form .categories' : 'updateSearch',
      'change .advancedSearch form .authors' : 'updateSearch',
      'change .advancedSearch form .breakers' : 'updateSearch'
    },

    tableView : TestsTableView,
    tableViewOptions : {
      collection : new TestTableCollection()
    },

    config : {
      sort : [ 'created_at desc' ],
      pageSize : 15
    },

    searchFilters : [
      { name : 'projects' },
      { name : 'tags' },
      {
        name : 'categories',
        blank : true,
        blankText : I18n.t('jst.testsTable.search.categories.blank')
      },
      {
        name : 'status',
        data : 'statuses',
        optionText : function(status) { return I18n.t('jst.testsTable.search.status.' + status); },
        sort : false
      },
      {
        name : 'authors',
        optionText : function(author) { return author.name; },
        optionValue : function(author) { return author.name; },
        sort : function(a, b) { return a.name.localeCompare(b.name); }
      },
      {
        name : 'breakers',
        optionText : function(breaker) { return breaker.name; },
        optionValue : function(breaker) { return breaker.name; },
        sort : function(a, b) { return a.name.localeCompare(b.name); }
      }
    ]
  });

  this.addAutoInitializer(function(options) {

    var Tests = TestTableCollection.extend({
      url : options.config.path
    });

    var Table = TestsTable.extend({
      tableViewOptions : {
        collection : new Tests()
      }
    });

    options.region.show(new Table(options.config));
  });
});


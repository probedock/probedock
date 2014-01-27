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
    template: function() {
      return _.template('<td colspan="7"><%- empty %></td>', { empty: I18n.t('jst.testsTable.empty') });
    }
  });

  var TestRow = Backbone.Marionette.ItemView.extend({

    tagName: 'tr',
    template: 'testsTable/row',

    ui: {
      name: '.name',
      project: '.project',
      author: '.author',
      createdAt: '.createdAt',
      key: '.key',
      action: '.action'
    },

    events: {
      'click': 'toggleSelected'
    },

    appEvents: {
      'test:selector': 'updateSelection',
      'test:selected': 'updateSelection',
      'test:deprecated': 'updateDeprecation'
    },

    initialize: function() {
      App.bindEvents(this);
    },

    onRender: function() {
      this.renderName();
      this.renderKey();
      this.renderProject();
      this.renderAuthor();
      this.ui.createdAt.text(Format.datetime.short(new Date(this.model.get('created_at'))));
      this.renderStatus();
      this.updateSelection();
    },

    updateSelection: function() {
      this.$el.removeClass('success warning');
      if (App.currentTestSelector) {
        this.$el.addClass(App.currentTestSelector.isSelected(this.model) ? 'success' : 'warning');
      }
    },

    updateDeprecation: function(test, deprecated) {
      if (this.model.toParam() == test.toParam()) {
        this.model.setDeprecated(deprecated);
        this.renderKey();
        this.renderStatus();
      }
    },

    renderName: function() {
      this.truncateLink(this.model.path(), this.model.get('name'), 75, this.ui.name);
    },

    renderKey: function() {

      var el = $('<span />');
      if (this.model.isDeprecated()) {
        $('<del />').text(this.model.get('key')).appendTo(el);
      } else {
        el.text(this.model.get('key'));
      }

      this.ui.key.html(el);
      Clipboard.setup(el, this.model.permalink(true), { title: I18n.t('jst.testsTable.keyTooltip') });
    },

    renderProject: function() {
      this.truncateLink(this.model.get('project').path(), this.model.get('project').get('name'), 22, this.ui.project);
    },

    truncateLink: function(href, text, max, el) {

      var link = $('<a />').attr('href', href),
          truncatedText = Format.truncate(text, { max: max });

      link.text(truncatedText);

      el.html(link);

      if (truncatedText != text) {
        link.tooltip({
          title: text
        });
      }
    },

    renderAuthor: function() {
      new UserAvatar({ model: this.model.get('author'), size: 'small', el: this.ui.author }).render();
    },

    isSelectionModeEnabled: function() {
      return !!(App.currentTestSelector);
    },

    toggleSelected: function(e) {
      if (!this.isSelectionModeEnabled()) {
        return;
      } else {
        e.preventDefault();
      }

      var selected = !App.currentTestSelector.isSelected(this.model);
      this.model.set({ selected: selected });
      App.trigger('test:selected', this.model, selected);
    },

    renderStatus: function() {

      var statusEl = $('<a class="btn btn-xs" />').attr('href', Path.build('runs', this.model.get('effective_result').get('test_run_id')));
      $('<span class="glyphicon glyphicon-' + (this.model.get('passing') ? 'thumbs-up' : 'thumbs-down') + '" />').appendTo(statusEl);

      if (this.model.isDeprecated()) {
        statusEl.addClass('btn-default');
      } else if (!this.model.get('active')) {
        statusEl.addClass('btn-warning');
      } else {
        statusEl.addClass('btn-' + (this.model.get('passing') ? 'success' : 'danger'));
      }

      this.ui.action.empty();
      statusEl.appendTo(this.ui.action).popover({
        html: true,
        trigger: 'hover',
        title: this.tooltipTitle(),
        content: this.tooltipContents(),
        placement: 'auto right'
      });
    },

    tooltipTitle: function() {
      return $('<strong />').text(I18n.t('jst.testsTable.lastRun'));
    },

    tooltipContents: function() {
      
      var wrapper = $('<div />');
      var effectiveResult = this.model.get('effective_result');
      var runner = effectiveResult.get('runner');

      var runnerEl = $('<div />').appendTo(wrapper);
      new UserAvatar({ model: runner, size: 'small', link: false, el: runnerEl }).render();

      var dl = $('<dl />');
      $('<dt />').text(I18n.t('jst.testsTable.lastRunDate')).appendTo(dl);
      $('<dd />').text(Format.datetime.short(new Date(this.model.get('last_run_at')))).appendTo(dl);
      $('<dt />').text(I18n.t('jst.testsTable.lastRunDuration')).appendTo(dl);
      $('<dd />').text(Format.duration(this.model.get('last_run_duration'), { shorten: 's' })).appendTo(dl);
      dl.appendTo(wrapper);

      $('<p class="text-warning runLink" />').text(I18n.t('jst.testsTable.goToLastRun')).appendTo(wrapper);

      return wrapper;
    }
  });

  var TestsTableView = Tableling.Bootstrap.TableView.extend({

    template: 'testsTable/table',
    itemView: TestRow,
    itemViewContainer: 'tbody',
    emptyView: NoTestRow,

    ui: {
      actionHeader: 'th.action',
      table: 'table'
    },

    events: {
      'click thead .selectAll': 'selectAll'
    },

    appEvents: {
      'test:selector': 'setSelectionModeEnabled renderActionHeader',
      'test:selected': 'renderActionHeader'
    },

    initialize: function() {

      Tableling.Bootstrap.TableView.prototype.initialize.apply(this, Array.prototype.slice.call(arguments));
      App.bindEvents(this);
      this.listenTo(this.vent, 'table:refreshed', this.renderActionHeader);

      // TODO: remove this once tableling has been fixed to avoid its events being overwritten
      this.events = _.extend(Tableling.Bootstrap.TableView.prototype.events, this.events);
    },

    onRender: function() {
      this.renderActionHeader();
    },

    selectAll: function() {

      var select = !this.allTestsAreSelected();

      this.collection.forEach(function(test) {
        if (App.currentTestSelector.isSelected(test) != select) {
          test.set({ selected: select });
          App.trigger('test:selected', test, select);
        }
      }, this);
    },

    allTestsAreSelected: function() {
      return this.collection.every(function(test) {
        return App.currentTestSelector.isSelected(test);
      });
    },

    setSelectionModeEnabled: function(enabled) {
      this.$el[enabled ? 'addClass' : 'removeClass']('selectionMode');
      this.ui.table[enabled ? 'removeClass' : 'addClass']('table-striped');
    },

    isSelectionModeEnabled: function() {
      return !!(App.currentTestSelector);
    },

    renderActionHeader: function() {
      if (this.isSelectionModeEnabled()) {
        this.renderSelectAll();
      } else {
        this.ui.actionHeader.text(I18n.t('jst.models.test.status'));
      }
    },

    renderSelectAll: function() {

      var selected = this.allTestsAreSelected();

      var el = $('<span class="selectAll glyphicon" />');
      this.ui.actionHeader.html(el);
      el.addClass('glyphicon-' + (selected ? 'minus' : 'plus') + '-sign');
      el.tooltip({ title: I18n.t('jst.testSelector.' + (selected ? 'unselectAll' : 'selectAll')) });
    }
  });

  var TestsTable = TableWithAdvancedSearch.extend({

    advancedSearchTemplate: 'testsTable/search',
    ui: {
      projectsFilter: '.advancedSearch form .projects',
      tagsFilter: '.advancedSearch form .tags',
      ticketsFilter: '.advancedSearch form .tickets',
      categoriesFilter: '.advancedSearch form .categories',
      authorsFilter: '.advancedSearch form .authors',
      breakersFilter: '.advancedSearch form .breakers',
      statusFilter: '.advancedSearch form .status'
    },

    events: {
      'change .advancedSearch form .status': 'updateSearch',
      'change .advancedSearch form .projects': 'updateSearch',
      'change .advancedSearch form .tags': 'updateSearch',
      'change .advancedSearch form .tickets': 'updateSearch',
      'change .advancedSearch form .categories': 'updateSearch',
      'change .advancedSearch form .authors': 'updateSearch',
      'change .advancedSearch form .breakers': 'updateSearch'
    },

    tableView: TestsTableView,
    tableViewOptions: {
      collection: new TestTableCollection()
    },

    config: {
      sort: [ 'created_at desc' ],
      pageSize: 15
    },

    searchFilters: [
      { name: 'projects' },
      { name: 'tags' },
      { name: 'tickets' },
      {
        name: 'categories',
        blank: true,
        blankText: I18n.t('jst.testsTable.search.categories.blank')
      },
      {
        name: 'status',
        data: 'statuses',
        optionText: function(status) { return I18n.t('jst.testsTable.search.status.' + status); },
        sort: false
      },
      {
        name: 'authors',
        optionText: function(author) { return author.name; },
        optionValue: function(author) { return author.name; },
        sort: function(a, b) { return a.name.localeCompare(b.name); }
      },
      {
        name: 'breakers',
        optionText: function(breaker) { return breaker.name; },
        optionValue: function(breaker) { return breaker.name; },
        sort: function(a, b) { return a.name.localeCompare(b.name); }
      }
    ]
  });

  this.addAutoInitializer(function(options) {

    var Tests = TestTableCollection.extend({
      url: options.config.path
    });

    var Table = TestsTable.extend({
      tableViewOptions: {
        collection: new Tests()
      }
    });

    options.region.show(new Table(options.config));
  });
});


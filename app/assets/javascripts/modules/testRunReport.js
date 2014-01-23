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
App.autoModule('testRunReport', function() {

  // Do not change order. Search for "STATUSES" to find uses.
  var STATUSES = [ 'passed', 'failed', 'inactive' ];

  var Report = Backbone.Marionette.ItemView.extend({

    template : false,

    ui : {
      details : '.details',
      detailsContainer : '.details .details-container',
      visualReport : '.visualReport',
      categoryResults : '.categoryResults',
      searchFilter : '.filters .search',
      tagsFilter : '.filters .tags',
      statusFilters : '.filters .status button',
      passedStatusFilter : '.filters .status .passed',
      failedStatusFilter : '.filters .status .failed',
      inactiveStatusFilter : '.filters .status .inactive',
      clearFilters : '.filters .clear',
      previousInGroup : '.group .previousInGroup',
      nextInGroup : '.group .nextInGroup'
    },

    events : {
      'change .filters .search' : 'filterBySearch',
      'change .filters .tags' : 'filterByTags',
      'click .visualReport a' : 'showResult',
      'click .details .showAll' : 'showAll',
      'click .filters .status button' : 'filterByStatus',
      'click .filters .clear' : 'clearFilters'
    },

    statuses : [ 'passed', 'failed', 'inactive' ],

    initialize: function(options) {
      this.config = options.config;
    },

    onRender : function() {

      this.setupGroupLinks();
      this.ui.tagsFilter.select2({ allowClear: true });
      this.ui.tagsFilter.select2('disable');

      this.tooltipStatusClasses = _.map(STATUSES, function(status) {
        return status.charAt(0);
      });

      this.tooltipStatuses = _.map(STATUSES, function(status) {
        return I18n.t('jst.testRunReport.tooltipMessage.' + status);
      });

      async.nextTick(_.bind(this.setupStatusFilterTooltips, this));
      setTimeout(_.bind(this.buildIndex, this), 300);
    },

    setupStatusFilterTooltips : function(e) {
      
      if (this.statusFilterTooltips) {
        _.each(this.statuses, function(status) {
          this.ui[status + 'StatusFilter'].tooltip('destroy');
        }, this);
      }
      this.statusFilterTooltips = true;

      _.each(this.statuses, function(status) {

        var el = this.ui[status + 'StatusFilter'],
            current = e && e.currentTarget == el.get(0),
            action = el.hasClass('active') ? 'hide' : 'show';

        if (current) {
          action = action == 'hide' ? 'show' : 'hide';
        }

        el.tooltip({ title : I18n.t('jst.testRunReport.statusFilter.' + status + '.' + action) });
        if (current) {
          el.tooltip('show');
        }
      }, this);
    },

    setupGroupLinks : function() {

      var config = App.pageConfig().testRun;
      if (!config) {
        throw new Error('Expected body data-config to contain testRun configuration');
      }

      if (!config.previous) {
        this.ui.previousInGroup.addClass('disabled');
        this.ui.previousInGroup.find('a').click(function() { return false; });
      }

      if (!config.next) {
        this.ui.nextInGroup.addClass('disabled');
        this.ui.nextInGroup.find('a').click(function() { return false; });
      }
    },

    setupTooltips : function() {
      var start = new Date().getTime();
      this.cards().each(_.bind(this.setupTooltip, this));
      App.debug('Set up tooltips in ' + (new Date().getTime() - start) + 'ms');
    },

    setupTooltip : function(i, el) {
      $(el).popover({
        trigger : 'hover',
        placement : 'top',
        title : this.tooltipTitle(i),
        content : this.tooltipContents(i),
        html : true
      });
    },

    tooltipTitle : function(i) {
      return JST['testRunReport/visualReportTooltipTitle']({
        klass: this.tooltipStatusClasses[this.testsIndex[i][2]],
        title: this.testsIndex[i][1]
      });
    },

    tooltipContents : function(i) {
      return JST['testRunReport/visualReportTooltipContents']({
        key: this.testsIndex[i][0],
        duration: this.testsIndex[i][3],
        result: this.tooltipStatuses[this.testsIndex[i][2]]
      });
    },

    cards : function() {
      return this._cards || (this._cards = this.ui.visualReport.find('.categoryResults a'));
    },

    details : function() {
      return this._details || (this._details = this.ui.details.find('.well'));
    },

    updateControls : function(sync) {

      if (typeof(sync) == 'undefined') {
        return async.nextTick(_.bind(this.updateControls, this, true));
      }

      var search = this.ui.searchFilter.val() && this.ui.searchFilter.val().length,
          tags = this.ui.tagsFilter.select2('val').length,
          status = _.find(this.statuses, function(s) {
            return !this.ui[s + 'StatusFilter'].hasClass('active');
          }, this);

      this.ui.clearFilters.attr('disabled', !(search || tags || status));
      this.updateNotices();
    },

    updateNotices : function() {
      
      this.ui.categoryResults.each(_.bind(function(i, el) {
        var container = $(el);
        this.noMatch(!container.find('a:visible').length, container);
      }, this));

      this.updateDetailsNotice();
    },

    updateDetailsNotice : function() {
      var c = this.ui.detailsContainer;
      this.noMatch(c.hasClass('onlyFailed') ? c.find('.f:first').length && !c.find('.f:visible').length : !c.find('.well:visible').length, c);
    },

    noMatch : function(enabled, container) {
      if (!enabled) {
        container.find('.noMatch').remove();
      } else if (!container.find('.noMatch').length) {
        $('<p class="muted noMatch" />').text(I18n.t('jst.testRunReport.noMatch')).appendTo(container);
      }
    },

    clearFilters : function() {

      this.ui.searchFilter.val('');
      this.filterBySearch(false);

      this.ui.tagsFilter.select2('data', null);
      this.filterByTags(false);

      this.ui.statusFilters.addClass('active');
      this.filterByStatus(false);

      this.setupStatusFilterTooltips();
      this.updateControls();
    },

    filterByStatus : function(e) {

      this.setupStatusFilterTooltips(e);

      if (e === false) {

        var klasses = _.collect(this.statuses, function(s) {
          return 'hide' + s.capitalize();
        }).join(' ');
        this.ui.visualReport.removeClass(klasses);
        this.ui.details.removeClass(klasses);

        return;
      }

      var el = $(e.currentTarget),
          func = el.hasClass('active') ? 'addClass' : 'removeClass',
          hideClass = 'hide' + _.find(this.statuses, function(s) {
            return el.hasClass(s);
          }).capitalize();

      this.ui.visualReport[func](hideClass);
      this.ui.details[func](hideClass);
      this.updateControls();
    },

    filterBySearch : function(update) {
      
      var search = this.ui.searchFilter.val(),
          cards = this.cards().removeClass('excludedBySearch'),
          details = this.details().removeClass('excludedBySearch');

      if (!search || !search.length) {
        return update !== false && this.updateControls();
      }

      var filter = _.bind(this.testMatches, this, search);
      cards.filter(filter).addClass('excludedBySearch');
      details.filter(filter).addClass('excludedBySearch');
      this.updateControls();
    },

    testMatches : function(search, i) {
      var test = this.testsIndex[i];
      return !(test[0].indexOf(search) != -1 || test[1].indexOf(search) != -1);
    },

    filterByTags : function(update) {

      var tags = this.ui.tagsFilter.select2('val'),
          cards = this.cards().removeClass('excludedByTags'),
          details = this.details().removeClass('excludedByTags');

      if (!tags.length) {
        return update !== false && this.updateControls();
      }

      var selector = _.map(tags, this.tagSelector, this).join(',');
      cards.not(selector).addClass('excludedByTags');
      details.not(selector).addClass('excludedByTags');
      this.updateControls();
    },

    tagSelector : function(tag) {
      return '.t' + this.tagsIndex.indexOf(tag).toString(36);
    },

    finalize : function() {
      this.ui.searchFilter.attr('disabled', false);
      this.ui.tagsFilter.select2('enable');
    },

    buildIndex : function() {

      var index = this.config.index;
      index.tests = [];

      var start = new Date().getTime();

      this.ui.details.find('.well').each(function() {
        var el = $(this);

        // STATUSES
        var status = 0;
        if (el.hasClass('f')) {
          status = 1;
        } else if (el.hasClass('i')) {
          status = 2;
        }

        index.tests.push([ el.find('.k').text(), el.find('h3 a').text(), status, el.find('.d').text() ]);
      });

      this.tagsIndex = index.tags;
      this.testsIndex = index.tests;
      App.debug('Built index of ' + this.testsIndex.length + ' tests in ' + (new Date().getTime() - start) + 'ms');

      this.finalize();

      async.nextTick(_.bind(this.setupTooltips, this));
    },

    showResult : function(e) {
      e.preventDefault();

      var link = $(e.target);
      var details = $(link.attr('href'));

      details.addClass('ignoreOnlyFailed');
      window.location.hash = link.attr('href');
      $.smoothScroll({
        scrollTarget : details,
        offset: -50,
        speed: 0
      });

      this.updateDetailsNotice();
    },

    showAll : function(e) {

      var button = $(e.target);
      button.attr('disabled', true);

      setTimeout(_.bind(function() {
        this.ui.detailsContainer.removeClass('onlyFailed');
        this.updateDetailsNotice();
      }, this), 50);
    }
  });

  var ReportLoader = Backbone.Marionette.ItemView.extend({

    template : false,

    ui : {
      progress : '.progress',
      progressBar : '.progress .progress-bar'
    },

    initialize : function(options) {
      this.path = options.config.path;
      this.interval = 1500;
    },

    onRender : function() {
      this.start = new Date().getTime();
      this.pollReport(10);
    },

    pollReport : function(n) {

      App.debug('Polling for report data...');

      $.ajax({
        url : this.path,
        dataType : 'html'
      }).done(_.bind(this.loadReport, this, n)).fail(_.bind(this.showError, this));
    },

    loadReport : function(n, response, statusText, xhr) {

      if (n <= 0) {
        this.showError(true);
      } else if (xhr.status == 204) {

        App.debug('Data not yet available; will poll again in ' + this.interval + 'ms');

        setTimeout(_.bind(this.pollReport, this, n - 1), this.interval);
        if (this.interval < 5000) {
          this.interval += 500;
        }

      } else {
        App.debug('Got report data after ' + (new Date().getTime() - this.start) + 'ms');
        this.showReport(response);
      }
    },

    showError : function(timeout) {
      timeout = timeout === true;
      this.ui.progress.removeClass('progress-striped active');
      this.ui.progressBar.addClass('progress-bar-' + (timeout ? 'warning' : 'danger'));
      $('<p />').addClass('text-' + (timeout ? 'warning' : 'danger'))
        .text(I18n.t('jst.testRunReport.loading' + (timeout ? 'Timeout' : 'Error')))
        .insertAfter(this.ui.progress).hide().slideDown();
    },

    showReport : function(html) {
      this.$el.fadeOut('normal', _.bind(function() {

        var parent = this.$el.parent();
        this.close();

        var el = $(html).appendTo(parent).hide().fadeIn();

        // Don't wait for the end of the fade in or
        // you can see select2 inputs being styled.
        new Report({ el: el, config: el.data('config') }).render();
      }, this));
    }
  });

  this.addAutoInitializer(function(options) {

    var el = $(options.region.el);
    if (options.config.loading) {
      options.region.attachView(new ReportLoader({ el: el, config: options.config }));
    } else {
      options.region.attachView(new Report({ el: el, config: options.config }));
    }

    options.region.currentView.render();
  });
});

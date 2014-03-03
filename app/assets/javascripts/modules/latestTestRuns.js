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
App.autoModule('latestTestRuns', function() {

  var LatestTestRunsCollection = App.models.TestRunCollection.extend({
    halUrl: [ { rel: 'v1:test-runs', template: { latest: '' } } ]
  });

  var EmptyRow = Marionette.ItemView.extend({

    tagName: 'tr',
    className: 'empty',
    template: function() {
      return _.template('<td colspan="2"><%- empty %></td>', { empty: I18n.t('jst.latestTestRuns.empty') });
    }
  });

  var TestRunDescription = Marionette.Layout.extend({

    template: _.template('<span class="runAvatar" /> <a href="<%- href %>"><%- label %> <span class="time"><%- time %></span></a>'),

    regions: {
      avatar: '.runAvatar'
    },

    ui: {
      link: 'a',
      avatar: '.runAvatar',
      time: '.time'
    },

    initialize: function() {
      this.listenTo(this, 'refreshTime', this.renderTime);
    },

    serializeData: function() {
      return {
        time: this.humanTime(),
        href: this.model.link('alternate').get('href'),
        label: this.isGroupDescription() ? this.model.get('group') : this.model.embedded('v1:runner').get('name')
      };
    },

    isGroupDescription: function() {
      return this.model.embedded('v1:runner').get('technical') && this.model.has('group');
    },

    renderTime: function() {
      this.ui.time.text(this.humanTime());
    },

    humanTime: function() {
      return moment(this.model.get('endedAt')).fromNow();
    },

    onRender: function() {
      if (this.isGroupDescription()) {
        this.ui.avatar.remove();
        this.ui.link.addClass('group');
      } else {
        this.avatar.show(new App.views.UserAvatar({ model: this.model.embedded('v1:runner'), size: 'small', label: false }));
      }
    }
  });

  var Row = Marionette.Layout.extend({
  
    tagName: 'tr',
    template: 'latestTestRuns/row',

    regions: {
      description: '.description',
      results: '.results'
    },

    initialize: function() {
      this.listenTo(this, 'refreshTime', this.renderTime);
    },

    onRender: function() {
      this.description.show(new TestRunDescription({ model: this.model }));
      this.results.show(new App.views.TestRunHealthBar({ model: this.model }));
    },

    renderTime: function() {
      this.description.currentView.trigger('refreshTime');
    }
  });

  var Table = Marionette.CompositeView.extend({

    template: 'latestTestRuns/table',
    tagName: 'table',
    className: 'table latestTestRuns',

    itemView: Row,
    itemViewContainer: 'tbody',
    emptyView: EmptyRow,

    onRender: function() {
      App.watchStatus(this, this.refresh, { only: 'lastApiPayload' });
      setInterval(_.bind(this.refreshTime, this), 15000);
    },

    refreshTime: function() {
      this.children.forEach(function(view) {
        view.trigger('refreshTime');
      });
    },

    refresh: function() {
      this.collection.fetch({ reset: true }).done(function() {
        App.debug('Updated latest test runs after new activity');
      });
    }
  });

  this.addAutoInitializer(function(options) {
    options.region.show(new Table({ collection: new LatestTestRunsCollection(options.config._embedded['v1:test-runs']) }));
  });
});

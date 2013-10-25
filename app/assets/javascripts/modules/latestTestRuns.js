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

App.autoModule('latestTestRuns', function() {

  var models = App.module('models'),
      TestRun = models.TestRun;

  var views = App.module('views'),
      UserAvatar = views.UserAvatar;

  var TestRunCollection = Backbone.Collection.extend({

    url: Path.builder('data', 'latest_test_runs'),
    model: TestRun
  });

  var EmptyRow = Backbone.Marionette.ItemView.extend({

    tagName: 'tr',
    className: 'empty',
    template: function() {
      return _.template('<td colspan="2"><%- empty %></td>', { empty: I18n.t('jst.latestTestRuns.empty') });
    }
  });

  var Row = Backbone.Marionette.ItemView.extend({
  
    tagName: 'tr',
    template: 'latestTestRuns/row',
    ui: {
      description: '.description',
      bar: '.progress',
      passedBar: '.bar-success',
      inactiveBar: '.bar-warning',
      failedBar: '.bar-danger'
    },

    events: {
      'click .progress': 'goToTestRun'
    },

    initialize: function() {
      this.listenTo(this.model.collection, 'refreshTime', this.renderTime);
    },

    onRender: function() {
      this.renderModel();
    },

    goToTestRun: function() {
      window.location = this.model.path();
    },

    humanTime: function() {
      return moment(this.model.get('ended_at')).fromNow();
    },

    renderModel: function() {
      this.renderDescription();
      this.renderResults();
    },

    renderTime: function() {
      if (!this.ui.time) {
        this.ui.time = this.$el.find('.description .time');
      }
      this.ui.time.text(this.humanTime());
    },

    renderResults: function() {

      var counts = this.model.counts(),
          percentages = this.model.percentages();

      _.each([ 'passed', 'inactive', 'failed' ], function(type) {

        var percentage = percentages[type];

        var bar = this.ui[type + 'Bar'];
        bar[percentage ? 'show' : 'hide']();

        if (percentage) {
          bar.css('width', percentage + '%');
          if (percentage >= 15) {
            bar.text(Format.number(counts[type]));
          } else {
            bar.empty();
          }
        }
      }, this);

      this.ui.bar.tooltip({
        title: this.model.successDescription()
      });
    },

    renderDescription: function() {

      this.ui.description.empty();
      var when = $('<span class="time" />').text(this.humanTime());
      var link = $('<a />').attr('href', this.model.path());

      if (!this.model.get('runner')) {
        var text = $('<strong />').text(this.model.get('group') + ' ');
        this.ui.description.html(link.html(text.append(when)));
      } else {
        new UserAvatar({ model: this.model.get('runner'), size: 'small', label: false, el: $('<div />').appendTo(this.ui.description) }).render();
        this.ui.description.append(link.text(this.model.get('runner').get('name') + ' ').append(when));
      }
    }
  });

  var Table = Backbone.Marionette.CompositeView.extend({

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
      this.collection.trigger('refreshTime');
    },

    refresh: function() {
      this.collection.fetch({ reset: true }).done(function() {
        App.debug('Updated latest test runs after new activity');
      });
    }
  });

  this.addAutoInitializer(function(options) {
    options.region.show(new Table({ collection: new TestRunCollection(options.config) }));
  });
});

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
App.autoModule('currentTestMetrics', function() {

  var models = App.module('models'),
      User = models.User;

  var UserMeasure = Backbone.RelationalModel.extend({

    relations: [
      {
        type: Backbone.HasOne,
        key: 'user',
        relatedModel: User
      }
    ]
  });

  var Measures = Backbone.RelationalModel.extend({

    relations: [
      {
        type: Backbone.HasMany,
        key: 'most',
        relatedModel: UserMeasure
      }
    ],

    hasUsers: function() {
      return this.get('most') && this.get('most').length;
    }
  });

  var Metrics = Backbone.RelationalModel.extend({

    relations: [
      {
        type: Backbone.HasOne,
        key: 'written',
        relatedModel: Measures
      },
      {
        type: Backbone.HasOne,
        key: 'deprecated',
        relatedModel: Measures
      },
      {
        type: Backbone.HasOne,
        key: 'run',
        relatedModel: Measures
      }
    ]
  });

  var CurrentMetrics = Backbone.RelationalModel.extend({
    
    url: Path.builder('data', 'current_test_metrics'),

    relations: [
      {
        type: Backbone.HasOne,
        key: 'today',
        relatedModel: Metrics
      },
      {
        type: Backbone.HasOne,
        key: 'week',
        relatedModel: Metrics
      },
      {
        type: Backbone.HasOne,
        key: 'month',
        relatedModel: Metrics
      }
    ]
  });

  var View = Backbone.Marionette.ItemView.extend({
    
    tagName: 'table',
    className: 'currentTestMetrics table table-bordered',
    template: 'currentTestMetrics/metrics',
    ui: {},

    metricTypes: [ 'written', 'run' ],
    metricTimes: [ 'today', 'week', 'month' ],

    initialize: function() {

      _.each(this.metricTypes, function(type) {
        _.each(this.metricTimes, function(time, i) {
          this.ui[type + time.capitalize()] = 'tbody tr.' + type + ' td:nth-child(' + (i + 2) + ')';
          this.ui[type + time.capitalize() + 'Most'] = 'tbody tr.' + type + 'Most td:nth-child(' + (i + 1) + ')';
        }, this);
      }, this);

      this.listenTo(this.model, 'change', this.renderMetrics);
    },

    onRender: function() {
      this.renderMetrics();
      App.watchStatus(this, this.refresh, { only: 'lastTestCounters' });
    },

    refresh: function() {
      this.model.fetch().done(function() {
        App.debug('Updated current test metrics after new activity');
      });
    },

    renderMetrics: function() {

      var type = 'run';
      _.each(this.metricTimes, function(time) {

        var selector = type + time.capitalize(),
            mostSelector = selector + 'Most',
            measures = this.model.get(time).get(type);

        // total written/run today/week/month
        var total = measures.get('total');

        this.ui[selector].text(Format.number(total));
        this.ui[selector][total ? 'removeClass' : 'addClass']('text-muted');

        if (measures.hasUsers()) {
          this.ui[mostSelector].removeClass('text-muted').empty();
          measures.get('most').forEach(function(m) {

            var total = m.get('total'),
                user = m.get('user');

            new (App.module('views').UserAvatar)({
              model: user,
              el: $('<div />').appendTo(this.ui[mostSelector]),
              size: 'small',
              label: false,
              tooltip: {
                title: I18n.t('jst.currentTestMetrics.tooltip.' + type + 'Text', {
                  user: user.get('name'),
                  n: Format.number(total),
                  time: I18n.t('jst.currentTestMetrics.tooltip.time.' + time)
                }),
                placement: 'bottom'
              }
            }).render();
          }, this);
        } else {
          this.ui[mostSelector].addClass('text-muted').text('n/a');
        }
      }, this);

      _.each(this.metricTimes, function(time) {

        var selector = 'written' + time.capitalize(),
            mostSelector = selector + 'Most',
            writtenMeasures = this.model.get(time).get('written'),
            deprecatedMeasures = this.model.get(time).get('deprecated');

        var writtenTotal = writtenMeasures.get('total'),
            writtenPrefix = writtenTotal && writtenTotal >= 1 ? '+' : '';

        this.ui[selector].empty();
        this.ui[mostSelector].empty();

        var newEl = $('<span />');
        newEl.text(writtenPrefix + Format.number(writtenTotal));
        newEl[writtenTotal ? 'removeClass' : 'addClass']('text-muted');
        newEl.removeClass('text-danger text-success');
        if (writtenTotal) {
          newEl.addClass('new');
          newEl.addClass(writtenTotal >= 1 ? 'text-success' : 'text-danger');
        }
        this.ui[selector].append(newEl);

        var deprecatedTotal = deprecatedMeasures.get('total');
        if (deprecatedTotal && deprecatedTotal >= 1) {

          var deprecatedEl = $('<span class="deprecated" />');
          deprecatedEl.text('-' + Format.number(deprecatedTotal));
          deprecatedEl.addClass('text-danger');
          if (!writtenTotal) {
            this.ui[selector].empty();
          } else {
            this.ui[selector].append(' ');
          }
          this.ui[selector].append(deprecatedEl);
        }

        if (writtenMeasures.hasUsers()) {
          this.ui[mostSelector].removeClass('text-muted').empty();
          writtenMeasures.get('most').forEach(function(m) {

            var total = m.get('total'),
                user = m.get('user');

            new (App.module('views').UserAvatar)({
              model: user,
              el: $('<div />').appendTo(this.ui[mostSelector]),
              size: 'small',
              label: false,
              tooltip: {
                title: I18n.t('jst.currentTestMetrics.tooltip.writtenText', {
                  user: user.get('name'),
                  n: Format.number(total),
                  time: I18n.t('jst.currentTestMetrics.tooltip.time.' + time)
                }),
                placement: 'bottom'
              }
            }).render();
          }, this);
        } else {
          this.ui[mostSelector].addClass('text-muted').text('n/a');
        }
      }, this);

      /*_.each(this.metricTypes, function(type) {
        _.each(this.metricTimes, function(time) {

          var selector = type + time.capitalize(),
              mostSelector = selector + 'Most',
              measures = this.model.get(time).get(type);

          // total written/run today/week/month
          var total = measures.get('total'),
              prefix = type == 'written' && total && total >= 1 ? '+' : '';

          this.ui[selector].text(prefix + Format.number(total));
          this.ui[selector][total ? 'removeClass' : 'addClass']('muted');
          this.ui[selector].removeClass('text-danger text-success');
          if (total && type == 'written') {
            this.ui[selector].addClass(total >= 1 ? 'text-success' : 'text-danger');
          }

          if (measures.hasUsers()) {
            this.ui[mostSelector].removeClass('muted').empty();
            measures.get('most').forEach(function(m) {

              var total = m.get('total'),
                  user = m.get('user');

              new (App.module('views').UserAvatar)({
                model: user,
                el: $('<div />').appendTo(this.ui[mostSelector]),
                size: 'small',
                label: false,
                tooltip: {
                  title: I18n.t('jst.currentTestMetrics.tooltip.' + type + 'Text', {
                    user: user.get('name'),
                    n: Format.number(total),
                    time: I18n.t('jst.currentTestMetrics.tooltip.time.' + time)
                  }),
                  placement: 'bottom'
                }
              }).render();
            }, this);
          } else {
            this.ui[mostSelector].addClass('muted').text('n/a');
          }
        }, this);
      }, this);*/
    }
  });

  this.addAutoInitializer(function(options) {
    options.region.show(new View({ model: new CurrentMetrics(options.config) }));
  });
});

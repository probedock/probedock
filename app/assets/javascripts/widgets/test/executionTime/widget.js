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
(function() {

  var models = App.module('models'),
      TestResultCollection = models.TestResultCollection,
      views = App.module('views');

  App.addTestWidget('executionTime', Marionette.ItemView, {

    ui: {
      chart: '.chart',
      resultSelector: '.resultSelector'
    },

    collectionEvents: {
      'reset': 'addResults',
      'error': 'showError'
    },

    initializeWidget: function(options) {
      this.collection = new (this.buildCollectionClass())();
      this.resultSelector = new views.TestResultSelector({ controller: options.controller });
      this.listenTo(this.resultSelector, 'update', this.updateResults);
    },

    onRender: function() {
      this.ensureResultSelectorRegion();
      this.resultSelectorRegion.show(this.resultSelector);
      this.renderChartAsync(_.bind(this.resultSelector.trigger, this.resultSelector, 'start'));
    },

    ensureResultSelectorRegion: function() {
      if (this.resultSelectorRegion) {
        this.resultSelectorRegion.close();
      } else {
        this.resultSelectorRegion = new Marionette.Region({ el: this.ui.resultSelector });
      }
    },

    renderChartAsync: function(callback) {
      async.nextTick(_.bind(this.renderChart, this, callback));
    },

    renderChart: function(callback) {

      this.chart = new Highcharts.Chart({

        title: false,

        chart: {
          renderTo: this.ui.chart.get(0),
          type: 'spline'
        },

        noData: {
          style: {
            fontWeight: 'bold',
            fontSize: '1.2em',
            top: '3em',
            color: '#c0c0c0'
          }
        },

        loading: {
          labelStyle: {
            fontWeight: 'bold',
            fontSize: '1.2em',
            top: '4em',
            color: '#245269'
          }
        },

        xAxis: {
          type: 'datetime',
          labels: {
            formatter: function() {
              return Format.date.short(new Date(this.value));
            }
          }
        },

        yAxis: {
          title: {
            text: I18n.t('jst.models.testResult.duration')
          },
          min: 0,
          labels: {
            formatter: function() {
              return Format.duration(this.value);
            }
          }
        },

        tooltip: {
          formatter: function() {

            var time = new Date(this.x);

            return Format.datetime.full(time)
              + '<br />'
              + '(' + moment(time).fromNow() + ')'
              + '<br />'
              + _.template('<strong><%- duration %>:</strong> ', { duration: I18n.t('jst.models.testResult.duration') })
              + Format.duration(this.y)
              + '<br />'
              + _.template('<strong><%- status %>:</strong> ', { status: I18n.t('jst.models.testResult.status') })
              + I18n.t('jst.testWidgets.executionTime.resultStatus.' + (this.point.result.get('passed') ? 'passed' : 'failed'))
              + '<br />'
              + _.template('<em><%- instructions %></em>', { instructions: I18n.t('jst.testWidgets.executionTime.pointInstructions') });
          }
        },

        plotOptions: {
          spline: {
            cursor: 'pointer',
            events: {
              click: _.bind(this.selectResult, this)
            }
          }
        },

        series: [
          {
            name: 'results',
            showInLegend: false,
            data: []
          }
        ]
      });

      callback();
    },

    selectResult: function(e) {
      this.controller.trigger('result:selected', e.point.result);
    },

    addResults: function() {

      this.chart.series[0].setData(this.collection.map(function(result) {
        return {
          x: result.get('runAt'),
          y: result.get('duration'),
          result: result,
          marker: {
            fillColor: result.get('passed') ? '#008b00' : '#ff0000'
          }
        };
      }).reverse());

      this.chart[this.collection.length ? 'hideNoData' : 'showNoData']();
    },

    updateResults: function(resultSelectorData) {

      var data = {
        sort: [ 'runAt desc' ],
        pageSize: resultSelectorData.size
      };

      if (resultSelectorData.version) {
        data.version = resultSelectorData.version;
      }

      this.ui.chart.next('.text-danger').remove();

      this.chart.showLoading();
      this.resultSelector.trigger('loading', true);

      this.collection.fetch({
        reset: true,
        data: data
      }).always(_.bind(this.resultSelector.trigger, this.resultSelector, 'loading', false), _.bind(this.chart.hideLoading, this.chart));
    },

    showError: function() {
      $('<p class="text-danger" />').text(this.t('error')).insertAfter(this.ui.chart).hide().slideDown();
    },

    buildCollectionClass: function() {
      return TestResultCollection.extend({
        url: this.model.link('v1:testResults').get('href')
      });
    },
  });
})();

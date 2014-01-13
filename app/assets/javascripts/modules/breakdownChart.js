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

App.autoModule('breakdownChart', function() {

  var Chart = Backbone.Marionette.ItemView.extend({

    template : false,

    initialize : function(options) {
      this.path = options.path;
      this.dimension = options.dimension;
      this.itemLabel = options.label;
      this.itemLink = options.link;
    },

    onRender : function() {
      async.nextTick(_.bind(this.renderChart, this));
    },
    
    renderChart : function() {

      var self = this;
      this.chart = new Highcharts.Chart({

        chart : {
          renderTo : this.$el.get(0),
          type : 'pie',
          events : {
            load : async.nextTick(_.bind(this.loadData, this))
          }
        },

        title : {
          text : I18n.t('jst.breakdownChart.title.' + this.dimension)
        },
        subtitle : {
          text : I18n.t('jst.breakdownChart.subtitle.' + this.dimension)
        },

        credits : false,
        lang : {
          loading : I18n.t('common.loading')
        },
        plotOptions: {
          pie: {
            cursor: 'pointer',
            point : {
              events : {
                click : function() {
                  self.goToItem(this);
                }
              }
            }
          }
        },
        tooltip : {
          formatter : function() {
            return _.template('<strong><%- item %>:</strong> ', { item : this.key }) + Format.number(this.y);
          }
        },
        series : []
      });
    },

    goToItem : function(point) {
      window.location.href = this.itemLink.replace(/000/, point.linkToken || point.name);
    },

    loadData : function() {
      this.chart.showLoading();
      $.ajax({
        url : this.path,
        dataType : 'json'
      }).done(_.bind(this.showData, this));
    },

    showData : function(response) {

      var items = _.first(_.sortBy(response, function(item) {
        return -item.count;
      }), 12);

      var max = _.max(items, function(item) {
        return item.count;
      });

      this.chart.addSeries({
        name : this.dimension,
        data : _.map(items, _.bind(function(item) {

          var name = item[this.dimension];
          if (name && this.itemLabel) {
            name = name[this.itemLabel];
          }

          var isMax = item == max;

          var point = {
            name : name || I18n.t('jst.breakdownChart.noItem.' + this.dimension),
            y : item.count,
            sliced : isMax,
            selected : isMax
          };

          if (!name) {
            point.linkToken = '+';
          }

          return point;
        }, this)).sort(function(a, b) {
          return a.name.localeCompare(b.name);
        })
      });
      this.chart.hideLoading();
    }
  });

  this.addAutoInitializer(function(options) {
    options.region.show(new Chart(options.config));
  });
});

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
App.autoModule('testInfo', function() {

  var models = App.module('models'),
      Test = models.Test,
      TestResult = models.TestResult,
      TestResultTableCollection = models.TestResultTableCollection;

  var views = App.module('views'),
      Table = views.Table,
      UserAvatar = views.UserAvatar;

  var TestInfo = Backbone.Marionette.Layout.extend({

    template : 'testInfo/info',
    regions : {
      info : '.info',
      actions : '.actions',
      tabs : '.tabs',
      result : '.result'
    },

    initialize : function() {
      this.listenTo(App.vent, 'test:result:selected', this.showResult);
      this.listenTo(App.vent, 'test:result:unselected', this.hideResult);
    },

    onRender : function() {
      this.info.show(new TestView({ model : this.model }));
      this.actions.show(new TestActions({ model : this.model }));
      this.tabs.show(new TestTabs({ model : this.model }));
      this.result.show(new NoResultDetails());
    },

    showResult : function(result) {
      this.result.show(new ResultDetails({ model : result }));
    },

    hideResult : function() {
      this.result.show(new NoResultDetails());
    }
  });

  var TestActions = Backbone.Marionette.ItemView.extend({
    
    template : 'testInfo/actions',
    ui : {
      deprecateButton : 'button.deprecate',
      undeprecateButton : 'button.undeprecate'
    },

    events : {
      'click .deprecate' : 'deprecate',
      'click .undeprecate' : 'undeprecate'
    },

    modelEvents: {
      'change': 'updateActions'
    },

    initialize : function() {
      this.listenTo(App.vent, 'maintenance:changed', this.updateControls);
    },

    onRender : function() {
      this.updateActions();
    },

    updateActions : function() {
      this.ui.deprecateButton[this.model.get('deprecated_at') ? 'hide' : 'show']();
      this.ui.undeprecateButton[this.model.get('deprecated_at') ? 'show' : 'hide']();
    },

    setBusy: function(busy) {
      this.busy = busy;
      this.updateControls();
    },

    updateControls: function() {
      this.ui.deprecateButton.attr('disabled', this.busy || App.maintenance);
      this.ui.undeprecateButton.attr('disabled', this.busy || App.maintenance);
    },

    deprecate : function() {
      this.setBusy(true);
      this.$el.find('.deprecationError').remove();
      $.ajax({
        url : Path.join(this.model.apiPath(), 'deprecate'),
        type : 'POST'
      }).done(_.bind(this.setDeprecated, this, true)).fail(_.bind(this.deprecationError, this));
    },

    undeprecate : function() {
      this.setBusy(true);
      this.$el.find('.deprecationError').remove();
      $.ajax({
        url : Path.join(this.model.apiPath(), 'undeprecate'),
        type : 'POST'
      }).done(_.bind(this.setDeprecated, this, false)).fail(_.bind(this.deprecationError, this));
    },

    setDeprecated : function(deprecated) {
      this.setBusy(false);
      this.model.set({ deprecated_at: deprecated ? new Date().getTime() : null });
    },

    deprecationError : function(xhr) {
      this.setBusy(false);
      if (xhr.status != 503) {
        Alerts.danger({ message: I18n.t('jst.testInfo.deprecationError'), fade: true }).addClass('deprecationError').appendTo(this.$el);
      }
    }
  });

  var TestView = Backbone.Marionette.ItemView.extend({
  
    template : 'testInfo/test',
    ui : {
      author : 'dd.author',
      project : 'dd.project',
      createdAt : 'dd.createdAt',
      category : 'dd.category',
      tags : 'dd.tags',
      tickets : 'dd.tickets',
      inactiveTitle : 'dt.inactive',
      inactiveInfo : 'dd.inactive',
      deprecateTitle : 'dt.deprecated',
      deprecateInfo : 'dd.deprecated',
      permalink : 'dd.permalink'
    },

    initialize : function() {
      this.listenTo(this.model, 'change', this.updateInactive);
      this.listenTo(this.model, 'change', this.updateDeprecated);
    },

    onRender : function() {
      this.ui.author.html(this.model.get('author').link());
      this.ui.project.html(this.model.get('project').link());
      this.ui.createdAt.text(Format.datetime.full(new Date(this.model.get('created_at'))));
      this.ui.category.html(this.model.categoryLink() || I18n.t('jst.common.noData'));
      this.ui.permalink.html($('<a />').attr('href', this.model.permalink()).text(this.model.permalink()));
      this.renderTags();
      this.renderTickets();
      this.updateInactive();
      this.updateDeprecated();
    },

    renderTickets : function() {
      if (!this.model.get('tickets') || !this.model.get('tickets').length) {
        return this.ui.tickets.text(I18n.t('jst.common.noData'));
      }
      this.model.get('tickets').sort(function(a, b) {
        return a.name.localeCompare(b.name);
      }).forEach(this.renderTicket, this);
    },

    renderTicket : function(ticket) {
      if (ticket.get('url')) {
        ticket.link().addClass('label label-warning').appendTo(this.ui.tickets);
      } else {
        $('<span class="label" />').text(ticket.get('name')).appendTo(this.ui.tickets);
      }
    },

    renderTags : function() {
      if (!this.model.get('tags') || !this.model.get('tags').length) {
        return this.ui.tags.text(I18n.t('jst.common.noData'));
      }
      _.each(this.model.get('tags').sort(), this.renderTag, this);
    },

    renderTag : function(tag) {
      $('<a class="label label-info" />').attr('href', PagePath.build('tests?' + $.param({ tags : [ tag ] }))).text(tag).appendTo(this.ui.tags);
    },

    updateInactive : function() {
      _.each([ this.ui.inactiveTitle, this.ui.inactiveInfo ], function(el) {
        el[this.model.get('active') ? 'hide' : 'show']();
      }, this);
    },

    updateDeprecated : function() {
      _.each([ this.ui.deprecateTitle, this.ui.deprecateInfo ], function(el) {
        el[this.model.get('deprecated_at') ? 'show' : 'hide']();
      }, this);
    }
  });

  var TestTabs = Backbone.Marionette.Layout.extend({

    template : 'testInfo/tabs',
    regions : {
      resultTable : '#resultTable',
      resultChart : '#resultChart',
      customValues : '#customValues'
    },

    onRender : function() {

      var id = window.location.hash;
      id = this.region(id) ? id : '#resultTable';
      this.$el.find('.nav-tabs li a[href="' + id + '"]').parent('li').addClass('active');
      this.$el.find('.tab-content ' + id).addClass('active in');
      this.activateTab(id);

      this.$el.find('a[data-toggle="tab"]').on('shown.bs.tab', _.bind(function(e) {
        this.activateTab($(e.target).attr('href'));
      }, this));
    },

    activateTab : function(id) {
      window.location.hash = id;
      this['show' + id.replace('#', '').underscore().capitalize().camelize()].apply(this);
    },

    region : function(id) {
      return this.regions[id.replace('#', '')];
    },

    showResultTable : function() {

      if (this.resultTableSetup) {
        return;
      }
      this.resultTableSetup = true;

      var Collection = TestResultTableCollection.extend({
        url : Path.join(this.model.apiPath(), 'results')
      });

      var Table = ResultTable.extend({
        tableViewOptions : {
          collection : new Collection()
        }
      });

      this.resultTable.show(new Table());
    },

    showResultChart : function() {

      if (this.resultChartSetup) {
        return;
      }
      this.resultChartSetup = true;

      this.resultChart.show(new ResultChart({ model : this.model }));
    },

    showCustomValues : function() {

      if (this.customValuesSetup) {
        return;
      }
      this.customValuesSetup = true;

      this.customValues.show(new CustomValues({ model : this.model }));
    }
  });

  var CustomValues = Backbone.Marionette.ItemView.extend({

    template : 'testInfo/values',
    ui : {
      list : 'dl'
    },

    onRender : function() {
      this.renderValues();
    },

    renderValues : function() {
      if (!this.model.get('values') || _.isEmpty(this.model.get('values'))) {
        return this.$el.empty().append($('<em />').text(I18n.t('jst.testInfo.noCustomValues')));
      }
      _.each(this.model.get('values'), function(value, name) {
        this.ui.list.append($('<dt />').text(name));
        this.ui.list.append($('<dd />').text(value));
      }, this);
    }
  });

  var ResultChart = Backbone.Marionette.ItemView.extend({

    template : false,

    initialize : function() {
      this.listenTo(App.vent, 'test:result:selected', this.setSelected);
      this.listenTo(App.vent, 'test:result:unselected', this.setSelected);
    },

    setSelected : function(result) {
      this.selectedResult = result;
    },

    onRender : function() {
      var self = this;
      async.nextTick(_.bind(function() {
        this.chart = new Highcharts.Chart({
          chart : {
            renderTo : this.$el.get(0),
            type : 'spline',
            events : {
              load : _.bind(this.loadResults, this)
            }
          },
          title : false,
          xAxis : {
            type : 'datetime',
            labels : {
              formatter : function() {
                return Format.date.short(new Date(this.value));
              }
            }
          },
          yAxis: {
            title : {
              text : I18n.t('jst.models.testResult.duration')
            },
            min : 0,
            labels : {
              formatter : function() {
                return Format.duration(this.value);
              }
            }
          },
          tooltip : {
            formatter : function() {
              return Format.datetime.full(new Date(this.x))
                + '<br />'
                + _.template('<strong><%- duration %>:</strong> ', { duration : I18n.t('jst.models.testResult.duration') })
                + Format.duration(this.y)
                + '<br />'
                + _.template('<strong><%- status %>:</strong> ', { status : I18n.t('jst.models.testResult.status') })
                + I18n.t('jst.testInfo.resultStatus.' + (this.point.result.get('passed') ? 'passed' : 'failed'))
                + '<br />'
                + _.template('<em><%- instructions %></em>', { instructions : I18n.t('jst.testInfo.resultPointInstructions') });
            }
          },
          plotOptions : {
            series : {
              cursor : 'pointer',
              point : {
                events : {
                  click : function() {
                    // FIXME: this produces a "RangeError: maximum call stack size exceeded" for some reason
                    if (self.selectedResult && self.selectedResult.get('id') == this.result.get('id')) {
                      App.vent.trigger('test:result:unselected');
                    } else {
                      App.vent.trigger('test:result:selected', this.result)
                    }
                  }
                }
              }
            }
          },
          series : []
        });
      }, this));
    },

    loadResults : function() {
      $.ajax({
        url : Path.join(this.model.apiPath(), 'results', 'chart'),
        dataType : 'json'
      }).done(_.bind(function(response) {
        this.chart.addSeries({
          name : 'results',
          showInLegend : false,
          data : _.map(response, function(result) {
            return {
              x : result.run_at,
              y : result.duration,
              result : TestResult.findOrCreate(result),
              marker : {
                fillColor : result.passed ? '#008b00' : '#ff0000'
              }
            };
          })
        });
      }, this));
    }
  });

  var ResultRow = Backbone.Marionette.ItemView.extend({

    tagName : 'tr',
    template : 'testInfo/resultRow',
    ui : {
      runner : '.runner',
      version : '.version',
      duration : '.duration',
      runAt : '.runAt'
    },

    events : {
      'click' : 'selectResult'
    },

    initialize : function() {
      this.listenTo(App.vent, 'test:result:selected', this.setSelected);
      this.listenTo(App.vent, 'test:result:unselected', this.setUnselected);
    },

    onRender : function() {
      this.renderRunner();
      this.ui.version.text(this.model.get('version') || I18n.t('jst.common.noData'));
      this.ui.duration.text(Format.duration(this.model.get('duration')));
      this.ui.runAt.text(Format.datetime.long(new Date(this.model.get('run_at'))));
      this.updateStyle();
    },

    renderRunner : function() {
      new UserAvatar({ model : this.model.get('runner'), size : 'small', el : this.ui.runner }).render();
    },

    selectResult : function() {
      if (this.$el.hasClass('warning')) {
        App.vent.trigger('test:result:unselected');
      } else {
        App.vent.trigger('test:result:selected', this.model);
      }
    },

    setSelected : function(result) {
      this.$el.removeClass('warning success danger');
      if (result == this.model) {
        this.$el.addClass('warning');
      } else {
        this.updateStyle();
      }
    },

    setUnselected : function() {
      if (this.$el.hasClass('warning')) {
        this.$el.removeClass('warning');
        this.updateStyle();
      }
    },

    updateStyle : function() {
      this.$el.addClass(this.model.get('passed') ? 'success' : 'danger');
    }
  });

  var ResultTableView = Tableling.Bootstrap.TableView.extend({

    template : 'testInfo/resultTable',
    itemView : ResultRow,
    itemViewContainer : 'tbody',

    initialize : function(options) {
      Tableling.Bootstrap.TableView.prototype.initialize.call(this, options);
      this.on('render', this.clearLoading, this);
    },
    
    clearLoading : function() {
      this.$el.find('.loading').remove();
    }
  });

  var ResultTable = Table.extend({

    tableView : ResultTableView,
    pageSizeViewOptions : {
      sizes : [ 5, 10, 15 ]
    },

    config : {
      pageSize : 5,
      sort : [ 'run_at desc' ]
    }
  });

  var NoResultDetails = Backbone.Marionette.ItemView.extend({

    className : 'well',
    template : function() {
      return _.template('<em><%- instructions %></em>', { instructions : I18n.t('jst.testInfo.resultInstructions') });
    }
  });

  var ResultDetails = Backbone.Marionette.ItemView.extend({

    className : 'well',
    template : 'testInfo/result',
    ui : {
      version : '.version',
      runAt : '.runAt',
      duration : '.duration',
      status : '.status',
      message : '.message'
    },

    initialize : function() {
      this.listenTo(this.model, 'change', this.renderModel);
    },

    onRender : function() {
      this.renderModel();
      this.model.fetch();
    },

    renderModel : function() {
      this.ui.version.text(this.model.get('version') || I18n.t('jst.common.noData'));
      this.ui.runAt.html(this.testRunLink());
      this.ui.duration.text(this.model.get('duration') ? Format.duration(this.model.get('duration')) : I18n.t('jst.common.noData'));
      this.ui.status.html(this.statusLabel());
      this.renderMessage();
    },

    testRunLink : function() {
      return $('<a />').attr('href', PagePath.build('runs', this.model.get('test_run_id'))).text(this.model.humanRunAt())
        .tooltip({ title : I18n.t('jst.testInfo.goToTestRun'), placement : 'right' });
    },

    statusLabel : function() {
      if (this.model.get('passed')) {
        return $('<span class="label label-success" />').text(I18n.t('jst.testInfo.resultStatus.passed'));
      } else {
        return $('<span class="label label-danger" />').text(I18n.t('jst.testInfo.resultStatus.failed'));
      }
    },

    renderMessage : function() {

      this.ui.message[this.model.get('message') ? 'show' : 'hide']();
      this.ui.message.text(this.model.get('message'));

      this.ui.message.removeClass('text-danger');
      if (!this.model.get('passed')) {
        this.ui.message.addClass('text-danger');
      }
    }
  });

  this.addAutoInitializer(function(options) {
    options.region.show(new TestInfo({ model : new Test(options.config) }));
  });
});

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
App.autoModule('appData', function() {

  var JobsData = Backbone.RelationalModel.extend({
    url : LegacyApiPath.builder('status', 'jobs')
  });

  var AppData = Backbone.RelationalModel.extend({
    url : LegacyApiPath.builder('status', 'app')
  });

  var TestsData = Backbone.RelationalModel.extend({
    url : LegacyApiPath.builder('status', 'tests')
  });

  var DbData = Backbone.RelationalModel.extend({

    url : LegacyApiPath.builder('status', 'db'),

    databaseSize : function() {
      return this.get('main') ? Math.round(this.get('main') / 10000) / 100 : undefined;
    },

    cacheSize : function() {
      return this.get('cache') ? Math.round(this.get('cache') / 10000) / 100 : undefined;
    }
  });

  var Data = Backbone.RelationalModel.extend({
    relations : [
      {
        type : Backbone.HasOne,
        key : 'app',
        relatedModel : AppData
      },
      {
        type : Backbone.HasOne,
        key : 'jobs',
        relatedModel : JobsData
      },
      {
        type : Backbone.HasOne,
        key : 'tests',
        relatedModel : TestsData
      },
      {
        type : Backbone.HasOne,
        key : 'db',
        relatedModel : DbData
      }
    ]
  });

  var AppDataView = Backbone.Marionette.ItemView.extend({

    template : 'appData',
    ui : {
      environment : 'td.environment',
      users : 'td.users',
      databaseSize : 'td.databaseSize',
      cacheSize : 'td.cacheSize',
      jobsWorkersRow : 'tr.workers',
      jobsWorkers : 'td.workers',
      jobsWorkingRow : 'tr.working',
      jobsWorking : 'td.working',
      jobsPendingRow : 'tr.pending',
      jobsPending : 'td.pending',
      jobsProcessed : 'td.processed',
      jobsFailedRow : 'tr.failed',
      jobsFailed : 'td.failed',
      tests : 'td.tests',
      testResults : 'td.results',
      testRuns : 'td.runs',
      jobControls : '.job-controls'
    },

    initialize : function() {
      this.listenTo(this.model.get('jobs'), 'change', this.renderJobs);
      this.listenTo(this.model.get('tests'), 'change', this.renderTests);
      this.listenTo(this.model.get('jobs'), 'change:processed', this.updateTests);
    },

    onRender : function() {

      this.renderGeneral();
      this.renderJobs();
      this.renderJobControls();
      this.renderTests();

      console.log('Updating data every ' + App.pollingFrequency + 'ms');

      this.jobsPolling = setInterval(_.bind(function() {
        this.model.get('jobs').fetch();
      }, this), App.pollingFrequency);
    },

    renderJobControls : function() {
      if (!this.model.get('admin')) {
        return this.ui.jobControls.remove();
      }

      $('<a />').attr('href', Path.builder('resque')).text(I18n.t('jst.appData.resqueLink')).appendTo(this.ui.jobControls);
    },

    renderTests : function() {

      var tests = this.model.get('tests');
      App.debug('Updating tests status');

      this.ui.tests.text(Format.number(tests.get('tests')));
      this.ui.testResults.text(Format.number(tests.get('results')));
      this.ui.testRuns.text(Format.number(tests.get('runs')));
    },

    updateTests : function() {
      this.model.get('tests').fetch();
    },

    renderGeneral : function() {

      var app = this.model.get('app');
      this.ui.environment.text(app.get('environment'));
      this.ui.users.text(Format.number(app.get('users')));

      var db = this.model.get('db');
      this.ui.databaseSize.text(db.databaseSize() ? db.databaseSize() + ' MB' : I18n.t('jst.common.noData'));
      this.ui.cacheSize.text(db.cacheSize() ? db.cacheSize() + ' MB' : I18n.t('jst.common.noData'));
    },

    renderJobs : function() {

      var jobs = this.model.get('jobs');
      App.debug('Updating jobs status');

      this.ui.jobsWorkers.text(Format.number(jobs.get('workers')));
      this.ui.jobsWorkersRow.removeClass('error success');
      this.ui.jobsWorkersRow.addClass(jobs.get('workers') > 0 ? 'success' : 'error');

      this.ui.jobsWorking.text(Format.number(jobs.get('working')));
      this.ui.jobsWorkingRow.removeClass('warning success');
      this.ui.jobsWorkingRow.addClass(jobs.get('working') > 0 ? 'warning' : 'success');

      this.ui.jobsPending.text(Format.number(jobs.get('pending')));
      this.ui.jobsPendingRow.removeClass('warning success');
      this.ui.jobsPendingRow.addClass(jobs.get('pending') > 0 ? 'warning' : 'success');

      this.ui.jobsProcessed.text(Format.number(jobs.get('processed')));

      this.ui.jobsFailed.text(Format.number(jobs.get('failed')));
      this.ui.jobsFailedRow.removeClass('error success');
      this.ui.jobsFailedRow.addClass(jobs.get('failed') > 0 ? 'error' : 'success');
    }
  });

  this.addAutoInitializer(function(options) {
    options.region.show(new AppDataView({ model : new Data(options.config) }));
  });
});

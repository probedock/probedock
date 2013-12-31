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
App.autoModule('testsData', function() {

  var models = App.module('models'),
      GeneralStatusData = models.GeneralStatusData;

  var TestsDataView = Backbone.Marionette.ItemView.extend({

    template : 'testsData',
    ui : {
      tests : '.tests',
      runs : '.runs',
      failing : '.failing',
      inactive : '.inactive',
      outdated : '.outdated'
    },

    initialize : function() {
      App.watchStatus(this, this.update, { except: [ 'jobs', 'lastTestCounters' ] });
      this.listenTo(this.model, 'change', this.renderModel);
    },

    onRender : function() {
      this.renderModel();
    },

    renderModel : function() {
      this.ui.tests.html(this.testsLink());
      this.ui.runs.html(this.runsLink());
      this.renderFailing();
      this.renderInactive();
      this.renderOutdated();
    },

    update : function() {
      this.model.fetch({
        data: {
          tests: 1,
          count: { tests: 1, runs: 1 }
        }
      }).done(function() {
        App.debug('Updated tests status after new activity');
      });
    },

    testsLink : function() {
      return $('<a />').attr('href', PagePath.build('tests')).text(Format.number(this.model.get('count').get('tests') - this.model.get('tests').get('deprecated')));
    },

    runsLink : function() {
      return $('<a />').attr('href', PagePath.build('runs')).text(Format.number(this.model.get('count').get('runs')));
    },

    renderFailing : function() {
      var n = this.model.get('tests').get('failing');
      var text = Format.number(n);
      if (n >= 1) {
        this.ui.failing.html($('<a />').attr('href', PagePath.build('tests?status=failing')).text(text));
      } else {
        this.ui.failing.text(text);
      }
    },

    renderInactive : function() {
      var n = this.model.get('tests').get('inactive');
      var text = Format.number(n);
      if (n >= 1) {
        this.ui.inactive.html($('<a />').attr('href', PagePath.build('tests?status=inactive')).text(text));
      } else {
        this.ui.inactive.text(text);
      }
    },

    renderOutdated : function() {
      var n = this.model.get('tests').get('outdated');
      var text = Format.number(n);
      if (n >= 1) {
        this.ui.outdated.html($('<a />').attr('href', PagePath.build('tests?status=outdated')).text(text));
        this.ui.outdated.tooltip({ title : I18n.t('jst.testsData.outdatedInstructions', { days : this.model.get('tests').get('outdatedDays') }), placement : 'bottom' });
      } else {
        this.ui.outdated.text(text);
      }
    }
  });

  this.addAutoInitializer(function(options) {
    options.region.show(new TestsDataView({ model : new GeneralStatusData(options.config) }));
  });
});

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

  var TestsData = Backbone.Model.extend({
  
    url : LegacyApiPath.builder('status', 'tests')
  });

  var TestsDataView = Backbone.Marionette.ItemView.extend({

    template : 'testsData',
    ui : {
      tests : '.tests',
      results : '.results',
      runs : '.runs',
      failing : '.failing',
      inactive : '.inactive',
      outdated : '.outdated'
    },

    initialize : function() {
      App.watchStatus(this, this.update, { except: 'lastTestCounters' });
      this.listenTo(this.model, 'change', this.renderModel);
    },

    onRender : function() {
      this.renderModel();
    },

    renderModel : function() {
      this.ui.tests.html(this.testsLink());
      this.ui.results.text(Format.number(this.model.get('results')));
      this.ui.runs.html(this.runsLink());
      this.renderFailing();
      this.renderInactive();
      this.renderOutdated();
    },

    update : function() {
      this.model.fetch({
        ifModified : true
      }).done(function() {
        App.debug('Updated tests status after new activity');
      });
    },

    testsLink : function() {
      return $('<a />').attr('href', PagePath.build('tests')).text(Format.number(this.model.get('tests')));
    },

    runsLink : function() {
      return $('<a />').attr('href', PagePath.build('runs')).text(Format.number(this.model.get('runs')));
    },

    renderFailing : function() {
      var n = this.model.get('failing_tests');
      var text = Format.number(n);
      if (n >= 1) {
        this.ui.failing.html($('<a />').attr('href', PagePath.build('tests?status=failing')).text(text));
      } else {
        this.ui.failing.text(text);
      }
    },

    renderInactive : function() {
      var n = this.model.get('inactive_tests');
      var text = Format.number(n);
      if (n >= 1) {
        this.ui.inactive.html($('<a />').attr('href', PagePath.build('tests?status=inactive')).text(text));
      } else {
        this.ui.inactive.text(text);
      }
    },

    renderOutdated : function() {
      var n = this.model.get('outdated_tests');
      var text = Format.number(n);
      if (n >= 1) {
        this.ui.outdated.html($('<a />').attr('href', PagePath.build('tests?status=outdated')).text(text));
        this.ui.outdated.tooltip({ title : I18n.t('jst.testsData.outdatedInstructions', { days : this.model.get('outdated_days') }), placement : 'bottom' });
      } else {
        this.ui.outdated.text(text);
      }
    }
  });

  this.addAutoInitializer(function(options) {
    options.region.show(new TestsDataView({ model : new TestsData(options.config) }));
  });
});

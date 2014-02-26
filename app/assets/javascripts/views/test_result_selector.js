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
App.module('views', function() {

  this.TestResultSelector = Marionette.ItemView.extend({

    tagName: 'form',
    className: 'form-inline',
    attributes: {
      role: 'form'
    },

    template: 'testResultSelector',

    ui: {
      sizeSelect: '[name="size"]',
      versionSelect: '[name="version"]'
    },

    events: {
      'change select': 'notifyUpdate'
    },

    initialize: function(options) {
      this.controller = options.controller;
      this.listenTo(this, 'start', this.notifyUpdate);
      this.listenTo(this, 'loading', this.setBusy);
    },

    onRender: function() {
      this.updateControls();
      this.loadProjectVersions();
    },

    setBusy: function(busy) {

      var wasBusy = this.busy;
      this.busy = !!busy;

      if (this.busy && !wasBusy) {
        Loader.loading().appendTo(this.$el);
      } else if (!this.busy && wasBusy) {
        Loader.clear(this.$el);
      }

      this.updateControls();
    },

    notifyUpdate: function() {

      var data = { size: parseInt(this.ui.sizeSelect.val(), 10) };
      
      var version = this.ui.versionSelect.val();
      if (version.length) {
        data.version = version;
      }

      this.trigger('update', data);
    },

    loadProjectVersions: function() {
      this.controller.projectVersions.load().done(_.bind(this.addProjectVersions, this));
    },

    addProjectVersions: function(collection) {

      collection.forEach(function(version) {
        $('<option />').attr('value', version.get('name')).text(version.get('name')).appendTo(this.ui.versionSelect);
      }, this);

      this.projectVersionsLoaded = true;
      this.updateControls();
    },

    updateControls: function() {
      this.ui.sizeSelect.attr('disabled', this.busy);
      this.ui.versionSelect.attr('disabled', this.busy || !this.projectVersionsLoaded);
    }
  });
});

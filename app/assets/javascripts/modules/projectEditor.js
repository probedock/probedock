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
App.autoModule('projectEditor', function() {

  var models = App.module('models'),
      Project = models.Project;

  var CreatorView = ApiForm.extend({

    modelClass: Project,
    template: 'projectEditor',
    ui: {
      title: '.panel-title',
      openButton: 'button.open',
      nameField: 'form input[name="name"]',
      urlTokenField: 'form input[name="urlToken"]',
      container: '.row.editor'
    },

    events: {
      'click button.open': 'open',
      'click button.cancel': 'close',
      'keyup form input[name="name"]': 'autoFillToken',
      'change form input[name="urlToken"]': 'disableAutoFillToken'
    },

    appEvents: {
      'maintenance:changed': 'updateControls'
    },

    initializeForm: function() {
      App.bindEvents(this);
    },

    onRender: function() {
      var type = this.model.isNew() ? 'create' : 'update';
      this.ui.openButton.text(I18n.t('jst.projectEditor.' + type));
      this.ui.title.text(I18n.t('jst.projectEditor.' + type + 'FormTitle'));
      this.updateControls();
    },

    updateControls: function() {
      this.ui.openButton.attr('disabled', !!App.maintenance);
    },

    renderModel: function() {
      this.ui.nameField.val(this.model.get('name'));
      if (this.model.get('urlToken')) {
        this.ui.urlTokenField.val(this.model.get('urlToken'));
      }
    },

    reset: function() {

      if (this.model.isNew()) {
        this.model.set({ name: null, token: null }, { silent: true });
      }
      this.renderModel();

      if (this.model.isNew() || this.model.get('urlToken') == this.nameToToken(this.model.get('name'))) {
        this.autoFillTokenEnabled = true;
        this.autoFillToken();
      }

      this.removeErrors();
    },

    nameToToken: function(name) {
      return name.titleize().replace(/\s+/g, '').replace(/[^a-z0-9\-\_]/ig, '').underscore().toLowerCase().substring(0, 25);
    },

    autoFillToken: function() {
      if (this.autoFillTokenEnabled) {
        this.ui.urlTokenField.val(this.nameToToken(this.ui.nameField.val()));
      }
    },

    disableAutoFillToken: function() {
      this.autoFillTokenEnabled = false;
    },

    open: function() {
      this.reset();
      this.ui.openButton.slideUp('normal', _.bind(function() {
        this.ui.container.slideDown('normal', _.bind(function() {
          this.ui.nameField.focus();
        }, this));
      }, this));
    },

    close: function() {
      this.ui.container.slideUp('normal', _.bind(function() {
        this.ui.openButton.slideDown('normal', _.bind(function() {
          this.updateFormControls();
        }, this));
      }, this));
    }
  });

  this.addAutoInitializer(function(options) {
    
    if (options.config && options.config.model) {
      options.config.model = new Project(options.config.model);
    }

    options.region.show(new CreatorView(options.config));
  });
});

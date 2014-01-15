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
App.autoModule('keyGenerator', function() {

  var models = App.module('models'),
      Project = models.Project,
      ProjectCollection = models.ProjectCollection;

  var KeyView = Backbone.Marionette.ItemView.extend({
    tagName: 'span',
    template: _.template('<span class="label label-success"><%- value %></span><span> </span>')
  });

  var NoKeyView = Backbone.Marionette.ItemView.extend({

    tagName: 'em',
    className: 'instructions',
    template: false,

    onRender: function() {
      this.$el.text(I18n.t('jst.keyGenerator.instructions'));
    }
  });

  var ProjectKeysView = Backbone.Marionette.CompositeView.extend({

    template: _.template('<p><strong><%- name %></strong></p>'),
    className: 'projectKeys',
    itemView: KeyView,

    initialize: function() {
      this.collection = this.model.get('testKeys');
    }
  });

  var MainView = Backbone.Marionette.CompositeView.extend({

    template: 'keyGenerator/layout',
    ui: {
      keys: '.keys',
      project: '.project',
      generate: 'form .generate',
      release: 'form .release',
      numberOfKeys: 'form [name="n"]',
      error: '.text-danger'
    },

    itemView: ProjectKeysView,
    emptyView: NoKeyView,
    itemViewContainer: '.well',

    events: {
      'click form .generate': 'generateNewKeys',
      'click form .release': 'releaseUnusedKeys'
    },

    initialize: function(options) {

      this.path = options.path;
      this.projects = options.projects;

      this.lastNumber = options.lastNumber;
      this.lastProjectApiId = options.lastProjectApiId;

      this.collection = new ProjectCollection();
      this.addKeys(options.freeKeys);

      this.listenTo(App.vent, 'maintenance:changed', this.updateControls);
    },

    onRender: function() {
      this.setupProject();
      this.updateControls();
      this.ui.error.hide();
    },

    addNewKeys: function(response) {
      this.addKeys(response._embedded['v1:test-keys']);
      this.busy = false;
      this.updateControls();
    },

    addKeys: function(keys) {

      _.each(keys, function(key) {

        var project = this.collection.find(function(p) {
          return p.get('apiId') == key.projectApiId;
        }, this);

        if (!project) {
          project = Project.findOrCreate(_.findWhere(this.projects, { apiId: key.projectApiId }));
          this.collection.add(project);
        }

        project.get('testKeys').add(key);
      }, this);
    },

    setupProject: function() {

      if (!this.projects || !this.projects.length) {
        return;
      }

      this.ui.project.find('option').remove();
      _.each(this.projects, function(project) {
        $('<option />').val(project.apiId).text(project.name).appendTo(this.ui.project);
      }, this);
      this.ui.project.attr('disabled', false);

      if (this.lastNumber && parseInt(this.lastNumber, 10) >= 1) {
        this.ui.numberOfKeys.val(this.lastNumber);
      }

      if (this.lastProjectApiId) {
        this.ui.project.val(this.lastProjectApiId);
      }
    },

    removeKeys: function() {

      this.collection.forEach(function(project) {
        project.get('testKeys').reset();
      }, this);

      this.collection.reset();

      this.busy = false;
      this.updateControls();
    },

    generateNewKeys: function() {

      this.ui.error.hide();

      this.busy = true;
      this.updateControls();

      $.ajax({
        url: this.path + '?' + $.param({ n: this.ui.numberOfKeys.val() }),
        type: 'POST',
        dataType: 'json',
        contentType: 'application/json',
        data: JSON.stringify({
          projectApiId: this.ui.project.val()
        })
      }).done(_.bind(this.addNewKeys, this)).fail(_.bind(this.showError, this, 'generate'));
    },

    releaseUnusedKeys: function() {
      if (!confirm(I18n.t('jst.keyGenerator.releaseConfirmation'))) {
        return;
      }

      this.ui.error.hide();

      this.busy = true;
      this.updateControls();

      $.ajax({
        url: this.path,
        type: 'DELETE',
        dataType: 'json'
      }).done(_.bind(this.removeKeys, this)).fail(_.bind(this.showError, this, 'release'));;
    },

    updateControls: function() {
      this.ui.generate.attr('disabled', this.busy || App.maintenance);
      this.ui.release.attr('disabled', this.busy || this.collection.isEmpty() || App.maintenance);
    },

    showError: function(type, xhr) {

      this.busy = false;
      this.updateControls();

      if (xhr.status != 503) {
        this.ui.error.text(I18n.t('jst.keyGenerator.errors.' + type)).show();
      }
    }
  });

  this.addAutoInitializer(function(options) {
    options.region.show(new MainView(options.config));
  });
});

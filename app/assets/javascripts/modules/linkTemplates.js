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
App.autoModule('linkTemplates', function() {

  var models = App.module('models'),
      LinkTemplate = models.LinkTemplate,
      LinkTemplateCollection = models.LinkTemplateCollection;

  var EmptyRow = Marionette.ItemView.extend({

    tagName: 'tr',
    className: 'empty',

    template: function() {
      return _.template('<td colspan="3"><%- empty %></td>', { empty: I18n.t('jst.linkTemplates.empty') });
    }
  });

  var LinkTemplateRow = Marionette.ItemView.extend({

    tagName: 'tr',
    template: 'linkTemplates/template',
    
    ui: {
      name: '.name',
      contents: '.contents',
      edit: '.actions .edit',
      editIcon: '.actions .edit .glyphicon',
      delete: '.actions .delete'
    },

    events: {
      'click .actions .edit': 'toggleEditing',
      'click .actions .delete': 'deleteTemplate'
    },

    modelEvents: {
      'change': 'renderModel'
    },

    appEvents: {
      'maintenance:changed': 'updateControls'
    },

    initialize: function() {
      this.listenTo(this.model, 'request', _.bind(this.setBusy, this, true));
      this.listenTo(this.model, 'sync error', _.bind(this.setBusy, this, false));
      this.listenTo(this.model, 'sync', _.bind(this.setEditing, this, false));
      this.listenTo(this, 'edit:start', _.bind(this.setEditing, this, true));
      this.listenTo(this, 'edit:stop', _.bind(this.setEditing, this, false));
      App.bindEvents(this);
    },

    onRender: function() {
      this.renderModel();
      this.updateControls();
    },

    toggleEditing: function(e) {
      e.preventDefault();
      this.trigger('edit:' + (this.editing ? 'stop' : 'start'));
    },

    deleteTemplate: function(e) {
      e.preventDefault();
      if (!confirm(I18n.t('jst.linkTemplates.confirmDelete', { name: this.model.get('name') }))) {
        return;
      }

      this.model.destroy({ wait: true });
    },

    setEditing: function(editing) {
      this.editing = editing;
      this.updateControls();
    },

    setBusy: function(busy) {
      this.busy = busy;
      this.updateControls();
    },

    renderModel: function() {
      this.ui.name.text(this.model.get('name'));
      this.ui.contents.text(this.model.get('contents'));
    },

    updateControls: function() {

      this.ui.edit.removeClass('btn-default btn-warning');
      this.ui.edit.addClass(this.editing ? 'btn-warning' : 'btn-default');
      this.ui.edit.attr('disabled', this.busy || App.maintenance);

      this.ui.editIcon.removeClass('glyphicon-remove-circle glyphicon-edit');
      this.ui.editIcon.addClass('glyphicon-' + (this.editing ? 'remove-circle' : 'edit'));

      this.ui.delete.attr('disabled', this.editing || this.busy || App.maintenance);
    }
  });

  var LinkTemplatesManager = Marionette.CompositeView.extend({

    template: 'linkTemplates/layout',
    itemView: LinkTemplateRow,
    itemViewContainer: 'tbody',
    emptyView: EmptyRow,

    ui: {
      form: 'tfoot form',
      name: 'tfoot form .name',
      contents: 'tfoot form .contents',
      save: 'tfoot form :submit'
    },

    events: {
      'keyup tfoot form input': 'updateControls',
      'submit tfoot form': 'saveTemplate'
    },

    appEvents: {
      'maintenance:changed': 'updateControls'
    },

    initialize: function() {
      this.listenTo(this, 'itemview:edit:start', this.editTemplate);
      this.listenTo(this, 'itemview:edit:stop', this.clearTemplate);
      App.bindEvents(this);
    },

    onRender: function() {
      this.setBusy(false);
    },

    editTemplate: function(child) {
      if (this.editingView) {
        this.editingView.trigger('edit:stop');
      }
      this.editingModel = child.model;
      this.editingView = child;
      this.ui.name.val(this.editingModel.get('name'));
      this.ui.contents.val(this.editingModel.get('contents'));
      this.updateControls();
      this.ui.name.focus();
    },

    saveTemplate: function(e) {
      e.preventDefault();
      this.setBusy(true);
      this.showErrors(false);

      var options = {
        success: _.bind(this.clearTemplate, this),
        error: _.bind(this.showErrors, this),
        wait: true
      };

      if (this.editingModel) {
        this.editingModel.save(this.templateData(), options);
      } else {
        this.collection.create(this.templateData(), options);
      }
    },

    clearTemplate: function() {
      delete this.editingModel;
      delete this.editingView;
      this.ui.name.val('');
      this.ui.contents.val('');
      this.showErrors(false);
      this.setBusy(false);
    },

    templateData: function() {
      return {
        name: this.ui.name.val(),
        contents: this.ui.contents.val()
      };
    },

    showErrors: function(model, xhr) {
      this.setBusy(false);
      Errors.show(model ? xhr : false, this.ui.form, 'link');
    },

    setBusy: function(busy) {
      this.busy = busy;
      this.updateControls();
    },

    updateControls: function(event) {

      // escape key
      if (event && event.keyCode && event.keyCode == 27) {
        if (this.editingView) {
          return this.editingView.trigger('edit:stop');
        } else {
          return this.clearTemplate();
        }
      }

      this.ui.save.removeClass('btn-default btn-primary');
      this.ui.save.text(I18n.t('jst.common.' + (this.editingModel ? 'save' : 'create')));

      var formHasValues = this.ui.name.val().length && this.ui.contents.val().length;
      this.ui.save.addClass(formHasValues ? 'btn-primary' : 'btn-default');
      this.ui.save.attr('disabled', !formHasValues || this.busy || App.maintenance);
      this.ui.name.attr('disabled', App.maintenance);
      this.ui.contents.attr('disabled', App.maintenance);
    }
  });

  this.addAutoInitializer(function(options) {
    options.region.show(new LinkTemplatesManager({ collection: new LinkTemplateCollection(options.config) }));
  });
});

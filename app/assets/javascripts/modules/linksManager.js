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
App.autoModule('linksManager', function() {

  var models = App.module('models'),
      LinkCollection = models.LinkCollection;

  var EmptyRow = Backbone.Marionette.ItemView.extend({

    tagName : 'tr',
    className : 'empty',
    template : function() {
      return _.template('<td colspan="3"><%- empty %></td>', { empty : I18n.t('jst.linksManager.empty') });
    }
  });

  var LinkRow = Backbone.Marionette.ItemView.extend({

    tagName : 'tr',
    template : 'linksManager/link',
    ui : {
      edit : '.actions .edit',
      delete : '.actions .delete',
      controls : '.actions .btn',
      name : '.name',
      url : '.url'
    },

    events : {
      'click .actions .edit' : 'editLink',
      'click .actions .delete' : 'deleteLink'
    },

    initialize : function() {
      this.listenTo(this.model, 'change', this.renderModel);
      this.listenTo(this, 'edit:stop', this.stopEditing);
    },

    onRender : function() {
      this.renderModel();
    },

    renderModel : function() {
      this.ui.name.text(this.model.get('name'));
      this.ui.url.text(this.model.get('url'));
      this.editing = false;
      this.updateControls();
    },

    editLink : function(e) {
      e.preventDefault();
      if (this.editing) {
        this.trigger('edit:stop');
      } else {
        this.trigger('edit');
        this.editing = true;
        this.updateControls();
      }
    },

    stopEditing : function() {
      this.editing = false;
      this.updateControls();
    },

    deleteLink : function(e) {
      e.preventDefault();
      if (!confirm(I18n.t('jst.linksManager.confirmDelete', { name: this.model.get('name') }))) {
        return;
      }

      this.updateControls(false);
      this.model.destroy({ wait : true });
    },

    updateControls : function(enabled) {

      this.ui.edit.attr('disabled', false);
      this.ui.edit.html($('<span class="glyphicon glyphicon-' + (this.editing ? 'remove-circle' : 'edit') + '" />'));
      this.ui.edit[this.editing ? 'addClass' : 'removeClass']('btn-warning');

      this.ui.delete.attr('disabled', this.editing);

      if (typeof(enabled) != 'undefined' && !enabled) {
        this.ui.controls.attr('disabled', true);
      }
    }
  });

  var LinksManager = Backbone.Marionette.CompositeView.extend({

    template : 'linksManager/manager',
    ui : {
      form : 'tfoot form',
      name : 'tfoot form .name',
      url : 'tfoot form .url',
      save : 'tfoot form button'
    },

    events : {
      'keyup tfoot form input' : 'updateControls',
      'submit tfoot form' : 'saveLink'
    },

    itemView : LinkRow,
    itemViewContainer : 'tbody',
    emptyView : EmptyRow,

    initialize : function() {
      this.listenTo(this, 'itemview:edit', this.editLink);
      this.listenTo(this, 'itemview:edit:stop', this.clear);
    },

    onRender : function() {
      this.updateControls();
    },

    editLink : function(child) {
      if (this.editingView) {
        this.editingView.trigger('edit:stop');
      }
      this.model = child.model;
      this.editingView = child;
      this.ui.name.val(this.model.get('name'));
      this.ui.url.val(this.model.get('url'));
      this.updateControls();
      this.ui.name.focus();
    },

    saveLink : function(e) {

      e.preventDefault();
      this.updateControls(false);
      this.showErrors(false);

      var options = {
        success : _.bind(this.clear, this),
        error : _.bind(this.showErrors, this),
        wait : true
      };

      if (this.model) {
        this.model.save(this.linkData(), options);
      } else {
        this.collection.create(this.linkData(), options);
      }
    },

    showErrors : function(model, xhr) {
      if (Errors.show(model ? xhr : false, this.ui.form, 'link') && model) {
        this.updateControls();
      }
    },

    updateControls : function(enabled) {

      if (enabled && enabled.keyCode && enabled.keyCode == 27) {
        if (this.editingView) {
          return this.editingView.trigger('edit:stop');
        } else {
          return this.clear();
        }
      }

      this.ui.save.removeClass('btn-primary');

      this.ui.save.text(I18n.t('common.' + (this.model ? 'save' : 'create')));

      if (this.ui.name.val().length && this.ui.url.val().length) {
        this.ui.save.addClass('btn-primary');
        this.ui.save.attr('disabled', false);
      } else {
        this.ui.save.attr('disabled', true);
      }

      if (typeof(enabled) != 'undefined' && !enabled) {
        this.ui.save.attr('disabled', true);
      }
    },

    clear : function() {
      delete this.model;
      delete this.editingView;
      this.ui.name.val('');
      this.ui.url.val('');
      this.showErrors(false);
      this.updateControls();
    },

    linkData : function() {
      return {
        name : this.ui.name.val(),
        url : this.ui.url.val()
      };
    }
  });

  this.addAutoInitializer(function(options) {
    options.region.show(new LinksManager({ collection : new LinkCollection(options.config) }));
  });
});

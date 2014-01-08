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
var ApiForm = Backbone.Marionette.ItemView.extend({

  formUi: {
    form: 'form',
    controls: 'button',
    formControls: 'form .form-controls .controls'
  },

  formEvents: {
    'click .save': 'save'
  },

  initialize: function() {

    _.defaults(this.ui || {}, this.formUi);
    _.defaults(this.events || {}, this.formEvents);

    if (!this.model && this.modelClass) {
      this.model = new (this.modelClass)();
    }
  },

  save: function(e) {
    e.preventDefault();

    this.removeErrors();
    this.setControlsEnabled(false);
    this.wasNew = this.model.isNew();
    this.oldPath = this.model.path();

    var data = _.inject(this.ui.form.serializeArray(), function(memo, e) {
      memo[e.name] = e.value;
      return memo;
    }, {});

    this.model.save(data, { dataType: 'json', wait: true }).fail(_.bind(this.onFailed, this)).done(_.bind(this.onSaved, this));
  },

  onSaved: function() {
    // TODO: find a clean way to update url, name and title
    if (this.wasNew || this.model.path() != this.oldPath) {
      window.location = this.model.path();
    } else {
      $('h2').text(this.model.get('name'));
      this.close();
    }
  },

  onFailed: function(xhr) {

    this.setControlsEnabled(true);

    if (xhr.status == 400) {
      this.showErrors($.parseJSON(xhr.responseText));
    } else {
      this.showGenericError({ message: I18n.t('jst.common.unexpectedModelError') });
    }
  },

  removeErrors: function() {
    this.ui.form.find('.form-group.has-error').removeClass('has-error');
    this.ui.form.find('.help-block.error').remove();
    this.ui.formControls.find('.text-danger').remove();
  },

  showErrors: function(response) {
    _.each(response.errors, this.showError, this);
    this.ui.form.find('.help-block.error, .form-controls .text-danger').hide().fadeIn();
  },

  showError: function(error) {
    if (error.path && error.path.match(/^\/[a-z0-9]+/i)) {

      var field = this.ui.form.find(':input[name="' + error.path.replace(/^\//, '') + '"]');
      if (field.length) {
        return this.showFieldError(error, field);
      }
    }

    this.showGenericError(error);
  },

  showFieldError: function(error, field) {

    var wrapper = field.parents('.form-group').first();
    wrapper.addClass('has-error');

    if (!wrapper.find('.help-block').length) {
      $('<span class="error help-block" />').text(error.message).appendTo(field.parent());
    }
  },

  showGenericError: function(error) {

    var first = false;
    
    var errorElement = this.ui.formControls.find('.text-danger');
    if (!errorElement.length) {
      first = true;
      errorElement = $('<p class="text-danger" />').appendTo(this.ui.formControls);
    }

    errorElement.append(first ? error.message : ', ' + error.message);
  },

  setControlsEnabled: function(enabled) {
    this.ui.controls.attr('disabled', !enabled);
  }
});

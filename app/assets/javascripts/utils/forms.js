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
var ApiForm = Marionette.ItemView.extend({

  formUi: {
    form: 'form',
    formSaveButton: 'form .form-controls .save',
    formCancelButton: 'form .form-controls .cancel',
    formControls: 'form .form-controls'
  },

  formEvents: {
    'click .save': 'save'
  },

  initialize: function() {

    this.ui = _.extend({}, this.formUi, this.ui);
    this.events = _.extend({}, this.formEvents, this.events);

    if (!this.model && this.modelClass) {
      this.model = new (this.modelClass)();
    }

    // do not use appEvents and App.bindEvents because appEvents might be overriden
    this.listenTo(App, 'maintenance:changed', this.updateFormControls);

    if (this.initializeForm) {
      this.initializeForm.apply(this, Array.prototype.slice.call(arguments));
    }
  },

  save: function(e) {
    e.preventDefault();

    this.removeErrors();
    this.setBusy(true);

    this.wasNew = this.model.isNew();
    this.oldPath = this.wasNew ? null : this.model.link('alternate').get('href');

    var data = _.inject(this.ui.form.serializeArray(), function(memo, e) {
      memo[e.name] = e.value;
      return memo;
    }, {});

    this.model.save(data, { wait: true }).fail(_.bind(this.onFailed, this)).done(_.bind(this.onSaved, this));
  },

  onSaved: function() {
    // TODO: find a clean way to update url, name and title
    if (this.wasNew || this.model.link('alternate').get('href') != this.oldPath) {
      window.location = this.model.link('alternate').get('href');
    } else {
      $('h2').text(this.model.get('name'));
      this.destroy();
    }
  },

  onFailed: function(xhr) {
    this.setBusy(false);

    if (xhr.status == 400) {
      this.showErrors($.parseJSON(xhr.responseText));
    } else if (xhr.status != 503) {
      this.showGenericError({ message: I18n.t('jst.common.unexpectedModelError') });
    }
  },

  setBusy: function(busy) {
    this.busy = busy;
    this.updateFormControls();
  },

  updateFormControls: function() {
    this.ui.formSaveButton.attr('disabled', this.busy || App.maintenance);
    this.ui.formCancelButton.attr('disabled', this.busy);
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
  }
});

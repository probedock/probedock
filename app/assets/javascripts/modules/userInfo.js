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
App.autoModule('userInfo', function() {

  var models = App.module('models'),
      User = models.User;

  var views = App.module('views'),
      UserAvatar = views.UserAvatar;

  var UserInfoView = Backbone.Marionette.Layout.extend({

    template: 'userInfo/layout',
    regions: {
      user: '.user'
    },

    initialize: function(options) {
      this.can = options.can;
    },

    onRender: function() {
      this.user.show(new InfoView({ model: this.model, can: this.can }));
    }
  });

  var InfoView = Backbone.Marionette.ItemView.extend({

    template: 'userInfo/info',
    ui: {
      avatar: '.title',
      email: '.email',
      active: 'dd.active',
      activeHeader: 'dt.active',
      createdAt: '.createdAt',
      actions: '.btn-group',
      editButton: '.edit',
      toggleActivatedButton: '.toggleActivated',
      deleteButton: '.delete'
    },

    events: {
      'click .delete': 'deleteUser',
      'click .toggleActivated': 'toggleActivated'
    },

    initialize: function(options) {
      this.can = options.can;
    },

    onRender: function() {
      this.renderAvatar();
      this.ui.email.text(this.model.get('email') || I18n.t('jst.common.noData'));
      this.ui.createdAt.text(Format.datetime.long(new Date(this.model.get('created_at'))));
      this.renderActive();
      this.renderActions();
    },

    renderAvatar: function() {
      new UserAvatar({ model: this.model, link: false, el: this.ui.avatar }).render();
    },

    renderActive: function() {
      if (this.can.manage) {
        this.ui.active.empty();
        this.ui.active.text(I18n.t('jst.common.' + !!this.model.get('active')));
        if (!this.model.get('active')) {
          $('<em class="text-warning" />').text(I18n.t('jst.userInfo.deactivatedInstructions')).appendTo(this.ui.active);
        }
      } else {
        this.ui.active.remove();
        this.ui.activeHeader.remove();
      }
    },

    renderActions: function() {

      if (!this.can.manage) {
        return this.ui.actions.hide();
      }
      this.ui.actions.show();

      this.ui.editButton.attr('href', this.model.editPath());
      this.ui.deleteButton.attr('disabled', !this.model.get('deletable'));
      this.updateToggleActivatedButton();
    },

    updateToggleActivatedButton: function() {
      this.ui.toggleActivatedButton.attr('disabled', false);
      this.ui.toggleActivatedButton.text(I18n.t('jst.userInfo.' + (this.model.get('active') ? 'deactivate' : 'activate')));
    },

    toggleActivated: function() {

      this.$el.find('.text-danger').remove();
      this.ui.toggleActivatedButton.attr('disabled', true);
      
      $.ajax({
        url: this.model.path(),
        type: 'PUT',
        data: {
          user: {
            active: !this.model.get('active')
          }
        }
      }).done(_.bind(this.setActivated, this)).fail(_.bind(this.showServerError, this, I18n.t('jst.userInfo.activationError')));
    },

    setActivated: function() {
      this.model.set({ active: !this.model.get('active') }, { silent: true });
      this.renderActive();
      this.updateToggleActivatedButton();
    },

    deleteUser: function() {
      if (!confirm(I18n.t('jst.userInfo.confirmDelete'))) {
        return;
      }

      this.$el.find('.text-danger').remove();

      $.ajax({
        url: this.model.path(),
        type: 'DELETE'
      }).done(_.bind(this.goBackToUsers, this)).fail(_.bind(this.showServerError, this, I18n.t('jst.userInfo.deletionError')));
    },

    goBackToUsers: function() {
      window.location = PagePath.build('users');
    },

    showServerError: function(errorMessage, xhr) {
      $('<p class="text-danger" />').text(errorMessage).appendTo(this.$el).hide().fadeIn();
      if (xhr.status == 409) {
        this.ui.deleteButton.attr('disabled', true);
      }
    }
  });

  this.addAutoInitializer(function(options) {
    options.region.show(new UserInfoView({ model: new User(options.config.user), can: options.config.can }));
  });
});

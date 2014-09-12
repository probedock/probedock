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
App.autoModule('userInfo', function() {

  var UserInfoView = Marionette.LayoutView.extend({

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

  var InfoView = Marionette.LayoutView.extend({

    template: 'userInfo/info',

    regions: {
      avatar: '.title'
    },

    ui: {
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

    modelEvents: {
      'change:active': 'renderActive updateControls',
      'destroy': 'goBackToUsers'
    },

    appEvents: {
      'maintenance:changed': 'updateControls'
    },

    initialize: function(options) {
      this.can = options.can;
      App.bindEvents(this);
    },

    onRender: function() {
      this.avatar.show(new App.views.UserAvatar({ model: this.model, link: false }));
      this.ui.email.text(this.model.get('email') || I18n.t('jst.common.noData'));
      this.ui.createdAt.text(Format.datetime.long(new Date(this.model.get('createdAt'))));
      this.renderActive();
      this.updateControls();
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

    setBusy: function(busy) {
      this.busy = busy;
      this.updateControls();
    },

    updateControls: function() {

      if (!this.can.manage) {
        return this.ui.actions.hide();
      }
      this.ui.actions.show();

      this.ui.editButton.attr('href', this.model.link('edit').get('href'));
      this.ui.editButton.attr('disabled', this.busy || App.maintenance);

      this.ui.toggleActivatedButton.attr('disabled', this.busy || App.maintenance);
      this.ui.toggleActivatedButton.text(I18n.t('jst.userInfo.' + (this.model.get('active') ? 'deactivate' : 'activate')));

      this.ui.deleteButton.attr('disabled', this.busy || !this.model.get('deletable') || this.undeletable || App.maintenance);
    },

    toggleActivated: function() {

      this.$el.find('.text-danger').remove();
      this.setBusy(true);

      this.model.save({
        active: !this.model.get('active')
      }, { patch: true }).always(_.bind(this.setBusy, this, false)).fail(_.bind(this.showServerError, this, I18n.t('jst.userInfo.activationError')));
    },

    deleteUser: function() {
      if (!confirm(I18n.t('jst.userInfo.confirmDelete'))) {
        return;
      }

      this.$el.find('.text-danger').remove();
      this.model.destroy({ wait: true }).fail(_.bind(this.showServerError, this, I18n.t('jst.userInfo.deletionError')));
    },

    goBackToUsers: function() {
      window.location = Path.build('users');
    },

    showServerError: function(errorMessage, xhr) {
      this.setBusy(false);

      if (xhr.status != 503) {

        $('<p class="text-danger" />').text(errorMessage).appendTo(this.$el).hide().fadeIn();
        if (xhr.status == 409) {
          this.undeletable = true;
          this.updateControls();
        }
      }
    }
  });

  this.addAutoInitializer(function(options) {
    options.region.show(new UserInfoView({ model: new App.models.User(options.config.user), can: options.config.can }));
  });
});

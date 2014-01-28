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

  var UserAvatar = this.UserAvatar = Backbone.Marionette.ItemView.extend({

    template: 'userAvatar',
    ui: {
      avatar: '.avatar',
      name: '.name'
    },

    initialize: function(options) {
      this.avatarSize = options.size;
      this.link = typeof(options.link) == 'undefined' || options.link;
      this.label = options.label !== false ? this.model.get('name') : undefined;
      this.tooltip = options.tooltip;
    },

    onRender: function() {

      this.$el.addClass(this.avatarSizeClass());
      this.renderAvatar();

      if (this.label) {
        this.renderLabel();
      } else {
        this.ui.name.remove();
      }

      if (this.tooltip) {
        this.ui.avatar.tooltip(_.isObject(this.tooltip) ? this.tooltip : { title: this.tooltip });
      }
    },

    renderLabel: function() {
      this.link ? this.ui.name.html($('<a />').attr('href', this.model.path()).text(this.label)) : this.ui.name.text(this.label);
    },

    renderAvatar: function() {
      var email = this.model.get('email') || 'example@lotaris.com';
      var img = $.gravatar(email, { size: this.avatarSizeValue(), secure: App.secure }).attr('alt', this.model.get('name'))
      this.ui.avatar.html(this.link ? $('<a />').attr('href', this.model.path()).append(img) : img);
    },

    avatarSizeValue: function() {
      if (this.avatarSize == 'small') {
        return 25;
      } else if (this.avatarSize == 'large') {
        return 40;
      } else {
        return 50;
      }
    },

    avatarSizeClass: function() {
      if (this.avatarSize == 'small') {
        return 'smallAvatar';
      } else if (this.avatarSize == 'large') {
        return 'mediumAvatar';
      } else {
        return 'largeAvatar';
      }
    }
  });
});

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
var Alerts = {

  clear: function(el) {
    el.find('.alert').remove();
  },

  build: function(options) {
    if (!options) {
      throw new Error("Alerts.build must be passed an options object.");
    } else if (!options.type) {
      throw new Error("Alerts.build options must contain a type.");
    } else if (!options.message) {
      throw new Error("Alerts.build options must contain a message.");
    }

    var el = $('<div class="alert" />');
    el.addClass('alert-' + options.type);

    if (!options.permanent) {
      el.addClass('alert-dismissable');
      $('<button type="button" class="close" data-dismiss="alert" aria-hidden="true" />').html('&times;').appendTo(el);
    }

    if (options.title) {
      $('<strong />').text(options.title).appendTo(el);
      el.append(' ');
    } else if (typeof(options.title) == 'undefined') {
      $('<strong />').text(I18n.t('jst.common.alert.' + options.type)).appendTo(el);
      el.append(' ');
    }

    el.append(options.message);

    if (options.fade) {
      el.addClass('fade');
      async.nextTick(_.bind(el.addClass, el, 'in'));
    }

    return el;
  }
};

_.each([ 'success', 'info', 'warning', 'danger' ], function(type) {
  Alerts[type] = function(options) {
    if (options) {
      options.type = type;
    }
    return Alerts.build(options);
  };
});

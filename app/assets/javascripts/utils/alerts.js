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
var Alerts = {

  error : function(translationKey) {
    return Alerts.buildAlert('danger', translationKey);
  },

  warning : function(translationKey) {
    return Alerts.buildAlert('warning', translationKey);
  },

  buildAlert : function(type, translationKey) {
    return $('<div class="alert alert-dismissable" />').addClass('alert-' + type).append(Alerts.closeButton()).append(Alerts.buildMessage(type, translationKey));
  },

  closeButton : function() {
    return $('<button type="button" class="close" data-dismiss="alert" aria-hidden="true" />').html('&times;');
  },

  buildMessage : function(type, translationKey) {
    return $('<span />').append($('<strong />').text(I18n.t('jst.common.alert.' + type))).append(' ' + I18n.t(translationKey)).html();
  }
};

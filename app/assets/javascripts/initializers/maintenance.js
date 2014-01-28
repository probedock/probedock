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
App.setMaintenance = function(maintenance) {
  
  var wasInMaintenance = !!App.maintenance;
  App.maintenance = maintenance ? maintenance : false;

  if (!!App.maintenance != wasInMaintenance) {

    App.debug((App.maintenance ? 'Started' : 'Ended') + ' maintenance mode.');
    App.trigger('maintenance:changed', App.maintenance);
    App.trigger('maintenance:' + (App.maintenance ? 'on' : 'off'));

    if (App.maintenance) {
      App.trigger('alert', {
        type: 'warning',
        class: 'alert-maintenance',
        title: I18n.t('jst.application.maintenance.title'),
        message: I18n.t('jst.application.maintenance.notice')
      });
    } else {
      $('.alert-maintenance').slideUp('normal', function() {
        $(this).remove();
      });
    }
  }
};

$(document).ajaxError(function(event, xhr) {
  if (xhr.status == 503 && xhr.getResponseHeader('Content-Type').match(/^application\/json/)) {
    App.setMaintenance(JSON.parse(xhr.responseText));
    App.trigger('ajax:maintenance');
  }
});

$(function() {
  var maintenanceData = Meta.get('maintenance');
  App.maintenance = maintenanceData ? JSON.parse(maintenanceData) : false;
});

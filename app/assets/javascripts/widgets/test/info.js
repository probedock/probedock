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
App.module('testWidgets', function() {

  this.Info = Marionette.Layout.extend({

    template: 'widgets/test/info/template',
    className: 'testWidget infoTestWidget',
    ui: {
      labels: '.labels'
    },

    serializeData: function() {
      return _.extend(this.model.toJSON(), {
        humanCreatedAt: Format.datetime.full(new Date(this.model.get('createdAt')))
      });
    },

    onRender: function() {
      this.renderLabels();
    },

    renderLabels: function() {

      this.ui.labels.empty();
      
      var tags = this.model.get('embedded').get('tags'),
          tickets = this.model.get('embedded').get('tickets');

      if (!tags.length && !tickets.length) {
        this.ui.labels.hide();
        return;
      }

      this.ui.labels.show();

      tags.forEach(function(tag) {
        $('<a class="label label-info" />').attr('href', tag.get('_links')['v1:tests'].href).text(tag.get('name')).appendTo(this.ui.labels);
      }, this);

      tickets.forEach(function(ticket) {
        $('<a class="label label-warning" />').attr('href', ticket.ticketHref()).text(ticket.get('name')).appendTo(this.ui.labels);
      }, this);
    }
  });
});

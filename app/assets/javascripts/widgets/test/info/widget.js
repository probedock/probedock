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
(function() {

  App.addTestWidget('info', Marionette.Layout, {

    ui: {
      author: '.author',
      project: '.project',
      labels: '.labels'
    },

    serializeData: function() {
      return _.extend(this.model.toJSON(), {
        humanCreatedAt: Format.datetime.full(new Date(this.model.get('createdAt'))),
        humanLastRunAt: Format.datetime.full(new Date(this.model.get('lastRunAt')))
      });
    },

    onRender: function() {
      this.renderAuthor();
      this.renderProject();
      this.renderLabels();
    },

    renderAuthor: function() {
      var author = this.model.embedded('v1:author');
      author.link('alternate').tag(author.get('name')).appendTo(this.ui.author);
    },

    renderProject: function() {
      var project = this.model.embedded('v1:project');
      project.link('alternate').tag(project.get('name')).appendTo(this.ui.project);
    },

    renderLabels: function() {

      this.ui.labels.empty();
      
      var category = this.model.embedded('v1:category'),
          tags = this.model.embedded('v1:tags'),
          tickets = this.model.embedded('v1:tickets');

      if (!category && !tags.length && !tickets.length) {
        this.ui.labels.hide();
        return;
      }

      this.ui.labels.show();

      if (category) {
        this.addLabelWithTooltip(category, 'search', 'name', 'primary', {
          title: this.t('goToCategory', { name: category.get('name') })
        });
      }

      tags.forEach(function(tag) {
        this.addLabelWithTooltip(tag, 'search', 'name', 'info', {
          title: this.t('goToTag', { name: tag.get('name') })
        });
      }, this);

      tickets.forEach(function(ticket) {
        this.addLabelWithTooltip(ticket, 'search', 'name', 'warning', {
          title: this.t(ticket.hasLink('about') ? 'goToExternalTicket' : 'goToTicket', { name: ticket.get('name') })
        }).attr('href', ticket.ticketHref());
      }, this);
    },

    addLabelWithTooltip: function(source, linkRel, labelProperty, labelType, options) {
      return source.link(linkRel).tag(source.get(labelProperty)).addClass('label label-' + labelType).tooltip(options).appendTo(this.ui.labels);
    }
  });
})();

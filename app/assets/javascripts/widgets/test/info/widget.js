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

  App.addTestWidget('info', Marionette.LayoutView, {

    regions: {
      author: 'dd.author'
    },

    ui: {
      project: '.project',
      labels: '.labels',
      lastRunAt: '.lastRunAt'
    },

    serializeData: function() {

      var createdAt = new Date(this.model.get('createdAt'));

      return _.extend(this.model.toJSON(), {
        humanCreatedAt: Format.datetime.full(createdAt) + ' (' + moment(createdAt).fromNow() + ')'
      });
    },

    onRender: function() {
      this.model.embedded('v1:project').linkTag().appendTo(this.ui.project);
      this.author.show(new App.views.UserAvatar({ model: this.model.embedded('v1:author'), size: 'small' }));
      this.renderLastRunAt();
      this.renderLabels();
    },

    renderLastRunAt: function() {
      this.ui.lastRunAt.empty();

      var lastRun = this.model.embedded('v1:lastRun'),
          endedAt = new Date(this.model.get('lastRunAt')),
          text = Format.datetime.full(endedAt) + ' (' + moment(endedAt).fromNow() + ')';

      if (lastRun) {
        lastRun.link('alternate').tag(text).appendTo(this.ui.lastRunAt);
      } else {
        this.ui.lastRunAt.text(text);
      }
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

      this.ui.labels.append(' ');
    },

    addLabelWithTooltip: function(source, linkRel, labelProperty, labelType, options) {
      this.ui.labels.append(' ');
      return source.link(linkRel).tag(source.get(labelProperty)).addClass('label label-' + labelType).tooltip(options).appendTo(this.ui.labels);
    }
  });
})();

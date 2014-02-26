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

  this.TestWidgetContainer = Marionette.Layout.extend({

    template: 'widgets/test',

    className: function() {
      return 'panel panel-info testWidget ' + this.model.id + 'TestWidget';
    },

    regions: {
      widgetBody: '.panel-body'
    },

    initialize: function(options) {
      this.controller = options.controller;
    },

    serializeData: function() {
      return _.extend(this.model.toJSON(), {
        title: I18n.t('jst.testWidgets.' + this.model.id + '.title')
      });
    },

    onRender: function() {
      this.showWidget();
    },

    showWidget: function() {
      var widgetClass = App.module('testWidgets')[this.model.id.underscore().camelize()];
      var widgetInstance = new widgetClass({ model: this.model.get('test'), widget: this.model, controller: this.controller });
      this.listenTo(widgetInstance, 'widget:status', this.changeStatus);
      this.widgetBody.show(widgetInstance);
    },

    changeStatus: function(status) {
      this.$el.removeClass('panel-default panel-primary panel-success panel-info panel-warning panel-danger').addClass('panel-' + status);
    }
  });
});

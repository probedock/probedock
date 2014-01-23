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
App.autoModule('testSelector', function() {

  var models = App.module('models'),
      Test = models.Test;

  var SelectedTests = Backbone.Collection.extend({
    model: Test
  });

  var NoSelection = Marionette.ItemView.extend({

    tagName: 'p',
    template: function() {
      return _.template('<em><%- instructions %></em>', { instructions: I18n.t('jst.testSelector.instructions') });
    }
  });

  var SelectedTest = Marionette.ItemView.extend({

    template: 'testSelector/selectedTest',

    onRender: function() {
      this.$el.text(this.model.get('name'));
    }
  });

  var AllSelected = Marionette.CompositeView.extend({

    template: false,
    itemView: SelectedTest,
    emptyView: NoSelection
  });

  var Layout = Marionette.Layout.extend({

    template: 'testSelector/layout',

    regions: {
      allSelected: '.allSelected'
    },

    ui: {
      openButton: '.open',
      selector: '.selector'
    },

    events: {
      'click .open': 'toggle',
      'click .close-selector': 'toggle'
    },

    initialize: function() {
      this.collection = new SelectedTests();
      this.listenTo(App, 'test:selected', this.selectTest);
      this.listenTo(App, 'test:unselected', this.unselectTest);
    },

    onRender: function() {
      this.ui.selector.hide();
      this.ui.openButton.tooltip({ title: I18n.t('jst.testSelector.description'), placement: 'auto right' });
      this.allSelected.show(new AllSelected({ collection: this.collection }));
    },

    selectTest: function(test) {
      this.collection.add(test);
    },

    unselectTest: function(test) {
      this.collection.remove(test);
    },

    toggle: function() {

      if (this.toggling) {
        return;
      }
      this.toggling = true;

      if (!this.shown) {
        this.ui.openButton.tooltip('hide');
        this.ui.openButton.slideUp('normal', _.bind(function() {
          this.ui.selector.slideDown('normal', _.bind(function() {
            this.shown = true;
            this.toggling = false;
            if (App.currentTestSelector) {
              throw new Error('There cannot be two test selectors active at the same time.');
            }
            App.currentTestSelector = this;
            App.trigger('test:selector', true);
          }, this));
        }, this));
      } else {
        delete App.currentTestSelector;
        App.trigger('test:selector', false);
        this.ui.selector.slideUp('normal', _.bind(function() {
          this.ui.openButton.slideDown('normal', _.bind(function() {
            this.shown = false;
            this.toggling = false;
          }, this));
        }, this));
      }
    }
  });
  
  this.addAutoInitializer(function(options) {
    options.region.show(new Layout());
  });
});

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

  var LinksView = Marionette.ItemView.extend({

    template: 'testSelector/links',

    ui: {
      text: 'textarea'
    },

    events: {
      'click textarea': 'selectText',
      'submit form': $.voidHandler
    },

    collectionEvents: {
      'add': 'renderText',
      'remove': 'renderText'
    },

    onRender: function() {
      this.renderText();
    },

    selectText: function() {
      this.ui.text.setSelection(0, this.ui.text.val().length);
    },

    renderText: function() {

      var text = '';
      
      this.collection.forEach(function(test, i) {
        if (i != 0) {
          text += '\n';
        }

        text += test.permalink(true);
      });

      this.ui.text.text(text);
    }
  });

  var NoSelection = Marionette.ItemView.extend({

    tagName: 'p',
    className: 'instructions',
    template: function() {
      return _.template('<em><%- instructions %></em>', { instructions: I18n.t('jst.testSelector.instructions') });
    }
  });

  var SelectedTest = Marionette.ItemView.extend({

    tagName: 'span',
    className: 'card',
    template: false,

    onRender: function() {
      this.$el.tooltip({ title: this.tooltipText(), html: true });
      this.setStatusClass();
    },

    setStatusClass: function() {
      this.$el.addClass(this.model.status() + 'Test');
    },

    tooltipText: function() {
      return $('<div />')
        .append($('<span />').text(this.model.get('project').get('name')))
        .append(' - ')
        .append($('<span class="monospace" />').text(this.model.get('key')))
        .append(' - ')
        .append($('<span />').text(this.model.get('name')));
    }
  });

  var AllSelected = Marionette.CompositeView.extend({

    template: 'testSelector/allSelected',
    itemView: SelectedTest,
    emptyView: NoSelection,

    collectionEvents: {
      'add': 'renderNumberSelected',
      'remove': 'renderNumberSelected'
    },

    ui: {
      numberSelected: '.numberSelected'
    },

    onRender: function() {
      this.renderNumberSelected();
    },

    renderNumberSelected: function() {
      this.ui.numberSelected.text(I18n.t('jst.testSelector.numberSelected', { count: this.collection.length }));
    }
  });

  var Layout = Marionette.Layout.extend({

    template: 'testSelector/layout',

    regions: {
      allSelected: '.allSelected',
      links: '.links'
    },

    ui: {
      openButton: '.open',
      selector: '.selector'
    },

    events: {
      'click .open': 'toggle',
      'click .close-selector': 'toggle'
    },

    appEvents: {
      'test:selected': 'changeTestSelection'
    },

    initialize: function() {
      App.bindEvents(this);
      this.collection = new SelectedTests();
    },

    onRender: function() {
      this.ui.selector.hide();
      this.ui.openButton.tooltip({ title: I18n.t('jst.testSelector.description'), placement: 'auto right' });
      this.allSelected.show(new AllSelected({ collection: this.collection }));
      this.links.show(new LinksView({ collection: this.collection }));
    },

    isSelected: function(test) {
      var needle = test.toParam();
      return this.collection.some(function(currentTest) {
        return needle == currentTest.toParam();
      });
    },

    changeTestSelection: function(test, selected) {
      this[selected ? 'selectTest' : 'unselectTest'](test);
    },

    selectTest: function(test) {
      this.collection.add(test);
    },

    unselectTest: function(test) {
      var testToRemove = this.findSelectedTest(test);
      if (testToRemove) {
        this.collection.remove(testToRemove);
      }
    },

    findSelectedTest: function(test) {
      var needle = test.toParam();
      return this.collection.find(function(currentTest) {
        return needle == currentTest.toParam();
      });
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

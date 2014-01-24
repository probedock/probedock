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
      Test = models.Test,
      LinkTemplateCollection = models.LinkTemplateCollection;

  var SelectedTests = Backbone.Collection.extend({
    model: Test
  });

  var LinkTemplateOption = Marionette.ItemView.extend({

    tagName: 'option',
    template: false,

    onRender: function() {
      this.$el.text(this.model.get('name'));
      this.$el.attr('value', this.model.get('contents'));
    }
  });

  var LinkTemplateSelector = this.LinkTemplateSelector = Marionette.CompositeView.extend({

    template: 'testSelector/templateSelector',
    itemView: LinkTemplateOption,
    itemViewContainer: 'select',

    ui: {
      select: 'select'
    },

    events: {
      'change': 'notifyChange'
    },

    notifyChange: function() {
      this.trigger('template:changed', this.ui.select.val());
    }
  });

  var LinksView = Marionette.Layout.extend({

    template: 'testSelector/links',

    regions: {
      templateSelectorRegion: '.templateSelector'
    },

    ui: {
      text: 'textarea',
      templateSelector: '.linkTemplateSelector',
      newLinesCheckbox: '.newLines',
      separator: '.linkSeparator'
    },

    events: {
      'click textarea': 'selectText',
      'submit form': $.voidHandler,
      'change .newLines': 'renderText',
      'keyup .linkSeparator': 'renderText'
    },

    collectionEvents: {
      'add': 'renderText',
      'remove': 'renderText'
    },

    initialize: function(options) {
      // TODO: store last selection in local storage

      this.linkTemplates = options.linkTemplates;
      this.linkTemplates.unshift({ name: I18n.t('jst.linkTemplates.noTemplate.name'), contents: I18n.t('jst.linkTemplates.noTemplate.contents') });
      this.currentTemplate = this.linkTemplates.at(0).get('contents');

      this.templateSelector = new LinkTemplateSelector({ collection: this.linkTemplates });
      this.listenTo(this.templateSelector, 'template:changed', this.changeTemplate);
    },

    onRender: function() {
      this.renderText();
      this.templateSelectorRegion.show(this.templateSelector);
    },

    changeTemplate: function(template) {
      this.currentTemplate = template;
      this.renderText();
    },

    selectText: function() {
      this.ui.text.setSelection(0, this.ui.text.val().length);
    },

    renderText: function() {

      var text = '',
          newLine = this.ui.newLinesCheckbox.is(':checked') ? '\n' : '',
          separator = this.ui.separator.val();
      
      this.collection.forEach(function(test, i) {
        if (i != 0) {
          text += newLine + separator;
        }

        text += this.buildLink(test);
      }, this);

      this.ui.text.text(text);
    },

    buildLink: function(test) {
      return this.currentTemplate.replace(/\%\{label\}/g, test.get('key')).replace(/\%\{url\}/g, test.permalink(true));
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
      selector: '.selector',
      clearSelectionButton: '.clearSelection'
    },

    events: {
      'click .open': 'toggle',
      'click .closeSelector': 'toggle',
      'click .clearSelection': 'clearSelection'
    },

    appEvents: {
      'test:selected': 'changeTestSelection'
    },

    initialize: function(options) {
      App.bindEvents(this);
      this.collection = new SelectedTests();
      this.linkTemplates = new LinkTemplateCollection(options.linkTemplates);
    },

    onRender: function() {
      this.ui.selector.hide();
      this.ui.openButton.tooltip({ title: I18n.t('jst.testSelector.description'), placement: 'auto right' });
      this.allSelected.show(new AllSelected({ collection: this.collection }));
      this.links.show(new LinksView({ collection: this.collection, linkTemplates: this.linkTemplates }));
      this.updateControls();
    },

    isSelected: function(test) {
      var needle = test.toParam();
      return this.collection.some(function(currentTest) {
        return needle == currentTest.toParam();
      });
    },

    clearSelection: function() {
      while (this.collection.length) {
        App.trigger('test:selected', this.collection.at(0), false);
      }
    },

    changeTestSelection: function(test, selected) {
      this[selected ? 'selectTest' : 'unselectTest'](test);
      this.updateControls();
    },

    updateControls: function() {
      this.ui.clearSelectionButton.attr('disabled', !this.collection.length);
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
    options.region.show(new Layout(options.config));
  });
});

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

  var ResultCard = Marionette.ItemView.extend({

    template: false,
    className: 'result',

    initialize: function() {
      this.status = this.model.status();
    },

    events: {
      'click': 'selectResult'
    },

    onRender: function() {
      this.renderStatus();
      this.renderTooltip();
    },

    selectResult: function() {
      this.trigger('result:selected', this.model);
    },

    renderStatus: function() {
      this.$el.removeClass('passedTest failedTest inactiveTest').addClass(this.status + 'Test');
    },

    renderTooltip: function() {
      this.$el.tooltip({
        title: I18n.t('jst.testWidgets.results.resultDescription.' + (this.model.get('passed') ? 'passed' : 'failed'), {
          time: this.humanRunAt(),
          version: this.model.get('version')
        })
      });
    },

    humanRunAt: function() {
      return Format.datetime.full(new Date(this.model.get('runAt')));
    }
  });

  App.addTestWidget('results', Marionette.CompositeView, {

    itemView: ResultCard,
    itemViewContainer: '.results',

    ui: {
      results: '.results',
      description: '.description',
      resultSelector: '.resultSelector'
    },

    collectionEvents: {
      'reset': 'updateDescription'
    },

    initializeWidget: function(options) {

      this.resultsModel = new App.models.TestResults();
      this.collection = this.resultsModel.embedded('item');

      this.controller = options.controller;
      this.resultSelector = new App.views.TestResultSelector({ controller: this.controller });

      this.listenTo(this.resultSelector, 'update', this.updateResults);
      this.listenTo(this, 'itemview:result:selected', this.selectResult);

      this.listenToOnce(this.collection, 'reset', function() {
        this.ui.results.show();
        this.ui.description.show();
      });
    },

    selectResult: function(view, result) {
      this.controller.trigger('result:selected', result);
    },

    onRender: function() {

      this.ui.results.hide();
      this.ui.description.hide();

      this.ensureResultSelectorRegion();
      this.resultSelectorRegion.show(this.resultSelector);
      this.resultSelector.trigger('start');
    },

    ensureResultSelectorRegion: function() {
      if (this.resultSelectorRegion) {
        this.resultSelectorRegion.close();
      } else {
        this.resultSelectorRegion = new Marionette.Region({ el: this.ui.resultSelector });
      }
    },

    onClose: function() {
      this.resultSelectorRegion.close();
    },

    updateResults: function(resultSelectorData) {

      var data = {
        pageSize: resultSelectorData.size,
        sort: [ 'runAt desc' ]
      };

      if (resultSelectorData.version) {
        data.version = resultSelectorData.version;
      }

      this.ui.description.next('.text-danger').remove();

      this.resultSelector.trigger('loading', true);

      this.model.link('v1:testResults').fetchResource({
        model: this.resultsModel,
        fetch: {
          data: data
        }
      }).always(_.bind(this.resultSelector.trigger, this.resultSelector, 'loading', false)).fail(_.bind(this.showError, this));
    },

    showError: function() {
      $('<p class="text-danger" />').text(this.t('error')).insertAfter(this.ui.description).hide().slideDown();
    },

    updateDescription: function() {
      if (this.collection.length == 1) {
        this.ui.description.text(this.t('description', {
          count: 1,
          time: Format.datetime.long(new Date(this.collection.at(0).get('runAt')))
        }));
      } else {
        this.ui.description.text(this.t('description', {
          count: this.collection.length, // NOTE: the first element is the most recent
          start: Format.datetime.long(new Date(this.collection.at(this.collection.length - 1).get('runAt'))),
          end: Format.datetime.long(new Date(this.collection.at(0).get('runAt')))
        }));
      }
    },

    // override marionette to render item views in reverse order
    appendHtml: function(compositeView, itemView, index) {
      if (compositeView.isBuffering) {
        $(compositeView.elBuffer).prepend(itemView.el);
        compositeView._bufferedChildren.push(itemView);
      } else {
        var $container = this.getItemViewContainer(compositeView);
        $container.prepend(itemView.el);
      }
    }
  });
})();

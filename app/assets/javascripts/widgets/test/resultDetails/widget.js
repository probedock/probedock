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

  var ExpandedView = Marionette.Layout.extend({

    className: 'modal fade',
    template: 'widgets/test/resultDetails/modal',

    regions: {
      runner: 'dd.runner'
    },

    ui: {
      title: '.modal-title .title',
      titleLabel: '.modal-title .status',
      titleSubtext: '.modal-title small',
      inactiveLabel: '.modal-title .inactive',
      project: '.project',
      test: '.test',
      version: '.version',
      message: '.message',
      noMessage: '.noMessage'
    },

    initialize: function(options) {
      this.listenTo(this, 'expand', this.expand);
      this.listenTo(options.controller, 'result:selected', this.renderResult);
    },

    onRender: function() {
      this.model.embedded('v1:project').linkTag().appendTo(this.ui.project);
      this.ui.test.text(this.model.get('name'));
    },

    expand: function() {
      this.$el.modal();
    },

    renderResult: function(result) {

      if (result.hasSameUri(this.currentResult)) {
        return;
      }
      this.currentResult = result;

      var passed = result.get('passed');

      this.ui.title.text(Format.datetime.full(new Date(result.get('runAt'))));
      this.ui.title.attr('href', result.embedded('v1:testRun').link('alternate').get('href'));
      this.ui.titleSubtext.text(Format.duration(result.get('duration')));

      this.ui.titleLabel.text(I18n.t('jst.testWidgets.resultDetails.status.' + (passed ? 'passed' : 'failed')));
      this.ui.titleLabel.removeClass('label-success label-danger').addClass(passed ? 'label-success' : 'label-danger');

      this.ui.inactiveLabel[result.get('active') ? 'hide' : 'show']();

      this.ui.version.text(result.get('version'));

      this.runner.show(new App.views.UserAvatar({ model: result.embedded('v1:runner'), size: 'small' }));

      this.renderMessage(result);
      this.listenToOnce(result, 'change:message', _.bind(this.renderMessage, this, result));
    },

    renderMessage: function(result) {

      var passed = result.get('passed'),
          hasMessage = result.has('message');

      if (hasMessage) {
        this.ui.message.text(result.get('message'));
        this.ui.message.removeClass('text-success text-danger').addClass(passed ? 'text-success' : 'text-danger');
      }

      this.ui.message[hasMessage ? 'show' : 'hide']();
      this.ui.noMessage[hasMessage ? 'hide' : 'show']();
    }
  });

  App.addTestWidget('resultDetails', Marionette.Layout, {

    regions: {
      expanded: '.expanded',
      runner: 'dd.runner'
    },

    ui: {
      version: '.version',
      runAt: '.runAt',
      duration: '.duration',
      message: '.details .message',
      noMessage: '.details .noMessage',
      details: '.details',
      instructions: '.instructions',
      expandButton: '.expand',
      statusLabel: '.status',
      inactiveLabel: '.inactive'
    },

    events: {
      'click .expand': 'expand'
    },

    initializeWidget: function(options) {
      this.listenTo(options.controller, 'result:selected', this.showResult);
      this.expandedView = new ExpandedView({ model: this.model, controller: options.controller, templateHelpers: this.templateHelpers });
    },

    onRender: function() {

      this.ui.details.hide();
      this.ui.message.hide();
      this.ui.noMessage.hide();

      this.ui.runAt.tooltip({ title: this.t('runAtTooltip') });
      this.ui.expandButton.tooltip({ title: this.t('expandTooltip') });

      this.expanded.show(this.expandedView);
    },

    onClose: function() {
      this.expanded.close();
    },

    showResult: function(result) {

      if (result.hasSameUri(this.currentResult)) {
        return;
      }
      this.currentResult = result;

      this.ui.version.text(result.get('version'));
      this.ui.duration.text(Format.duration(result.get('duration')));

      var testRun = result.embedded('v1:testRun'),
          runAt = new Date(result.get('runAt'));

      this.ui.runAt.html(testRun.link('alternate').tag(Format.datetime.full(runAt) + ' (' + moment(runAt).fromNow() + ')'));

      this.runner.show(new App.views.UserAvatar({ model: result.embedded('v1:runner'), size: 'small' }));

      var passed = result.get('passed');
      this.ui.statusLabel.removeClass('label-success label-danger').addClass('label-' + (passed ? 'success' : 'danger'));
      this.ui.statusLabel.text(this.t('status.' + (passed ? 'passed' : 'failed')));
      this.ui.inactiveLabel[result.get('active') ? 'hide' : 'show']();

      if (!this.shown) {
        this.ui.instructions.slideUp();
        this.shown = true;
        this.ui.details.slideDown('normal', _.bind(this.fetchMessage, this, result));
      } else {
        this.fetchMessage(result);
      }
    },

    expand: function() {
      this.expandedView.trigger('expand');
    },

    fetchMessage: function(result) {
      this.ui.message.prev('.error').remove();
      result.fetch().done(_.bind(this.renderMessage, this, result)).fail(_.bind(this.showMessageError, this));
    },

    showMessageError: function() {
      this.ui.message.slideUp();
      this.ui.noMessage.slideUp();
      $('<p class="error text-danger" />').text(this.t('messageError')).insertBefore(this.ui.message).hide().slideDown();
    },

    renderMessage: function(result) {

      var hasMessage = result.has('message');

      if (hasMessage) {
        this.ui.message.text(result.get('message'));

        this.ui.message.removeClass('text-danger');
        if (!result.get('passed')) {
          this.ui.message.addClass('text-danger');
        }
      }

      this.ui.message[hasMessage ? 'slideDown' : 'slideUp']();
      this.ui.noMessage[hasMessage ? 'slideUp' : 'slideDown']();
    }
  });
})();

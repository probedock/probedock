angular.module('probedock.newTestsWidget').directive('newTestsWidget', function () {
  return {
    restrict: 'E',
    templateUrl: '/templates/widgets/new-tests/newtests.template.html',
    scope: {
      organization: '=',
      hideSelect: '=?',
      user: '=?'
    }
  }
}).directive('newTestsWidgetContent', function () {
  return {
    restrict: 'E',
    templateUrl: '/templates/widgets/new-tests/newtests.content.template.html',
    controller: 'NewTestsContentCtrl',
    scope: {
      organization: '=',
      hideSelect: '=?',
      user: '=?'
    }
  }
});
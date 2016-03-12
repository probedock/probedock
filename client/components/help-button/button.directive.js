angular.module('probedock.helpButton').directive('helpButton', function() {
  return {
    restrict: 'E',
    templateUrl: '/templates/components/help-button/button.template.html',
    transclude: true,
    replace: true
  };
});

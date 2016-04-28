angular.module('probedock.labelRequired').directive('labelRequired', function() {
  return {
    restrict: 'E',
    transclude: true,
    replace: true,
    templateUrl: '/templates/components/label-required/required.template.html',
    scope: {
      label: '@'
    }
  };
});

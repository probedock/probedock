angular.module('probedock.labelRequired').directive('labelRequired', function() {
  return {
    restrict: 'E',
    templateUrl: '/templates/components/label-required/required.template.html',
    scope: {
      label: '@',
      for: '@'
    }
  };
});

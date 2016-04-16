angular.module('probedock.bootstrap').directive('bootstrapSizeDetector', function(bootstrap, $window, $timeout) {
  return {
    restrict: 'E',
    template: '<div class="hidden-sm" /><div class="hidden-md" /><div class="hidden-lg" />',
    scope: {},
    link: function($scope, elem, attrs) {

      var smElement = elem.find('.hidden-sm'),
          mdElement = elem.find('.hidden-md'),
          lgElement = elem.find('.hidden-lg');

      $scope.$watch(function() {

        var size = 'xs';
        if (lgElement.is(':hidden')) {
          size = 'lg';
        } else if (mdElement.is(':hidden')) {
          size = 'md';
        } else if (smElement.is(':hidden')) {
          size = 'sm';
        }

        bootstrap.setSize(size);
      });
    }
  };
});

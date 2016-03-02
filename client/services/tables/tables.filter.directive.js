angular.module('probedock.tables').directive('filters', function (stConfig, $timeout) {
  return {
    restrict: 'A',
    require: '^stTable',
    scope: {
      filters: '='
    },
    link: function ($scope, element, attr, ctrl) {
      $scope.$watch('filters', function () {
        ctrl.pipe();
      }, true);
    }
  };
});
angular.module('probedock.tables').directive('stFilters', function () {
  return {
    restrict: 'A',
    require: '^stTable',
    scope: {
      stFilters: '='
    },
    link: function ($scope, element, attr, ctrl) {
      $scope.$watch('stFilters', function () {
        ctrl.slice(0, ctrl.tableState().pagination.number);
      }, true);
    }
  };
});

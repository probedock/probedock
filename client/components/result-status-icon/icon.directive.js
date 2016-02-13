angular.module('probedock.resultStatusIcon').directive('resultStatusIcon', function() {
  return {
    restrict: 'E',
    controller: 'ResultStatusIconCtrl',
    templateUrl: '/templates/components/result-status-icon/icon.template.html',
    scope: {
      result: '='
    }
  };
}).controller('ResultStatusIconCtrl', function($scope) {
  $scope.ready = false;

  $scope.$watch('result', function (value) {
    if (value) {
      $scope.passed = ($scope.result.passed || $scope.result.passing) && $scope.result.active;
      $scope.failed = !($scope.result.passed || $scope.result.passing) && $scope.result.active;
      $scope.active = !$scope.result.active;
      $scope.ready = true;
    }
  });
});
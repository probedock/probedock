angular.module('probedock.testStatusIcon').directive('testStatusIcon', function() {
  return {
    restrict: 'E',
    controller: 'TestStatusIconCtrl',
    templateUrl: '/templates/components/test-status-icon/icon.template.html',
    scope: {
      result: '=',
      test: '='
    }
  };
}).controller('TestStatusIconCtrl', function($scope) {
  $scope.ready = false;

  $scope.$watch('test', function (value) {
    if (value) {
      $scope.passed = $scope.test.passing && $scope.test.active;
      $scope.failed = !$scope.test.passing && $scope.test.active;
      $scope.active = !$scope.test.active;
      $scope.ready = true;
    }
  });

  $scope.$watch('result', function (value) {
    if (value) {
      $scope.passed = $scope.result.passed && $scope.result.active;
      $scope.failed = !$scope.result.passed && $scope.result.active;
      $scope.active = !$scope.result.active;
      $scope.ready = true;
    }
  });
});
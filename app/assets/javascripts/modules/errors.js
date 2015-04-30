angular.module('probe-dock.errors', [])

  .controller('ErrorPageCtrl', function($scope, $stateParams) {
    if ($stateParams.type == 'unauthorized') {
      $scope.message = 'You are not logged in.';
    } else if ($stateParams.type == 'forbidden') {
      $scope.message = 'You are not authorized to access this page.';
    } else {
      $scope.message = 'An unexpected error occurred.';
    }
  })

;

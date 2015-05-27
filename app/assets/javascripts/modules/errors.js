angular.module('probedock.errors', [])

  .controller('ErrorPageCtrl', function($scope, $stateParams) {
    if ($stateParams.type == 'unauthorized') {
      $scope.message = 'You are not logged in.';
    } else if ($stateParams.type == 'forbidden') {
      $scope.message = 'You are not authorized to access this page.';
    } else if ($stateParams.type == 'notFound') {
      $scope.message = "The page you're looking for no longer exists.";
    } else {
      $scope.message = 'An unexpected error occurred.';
    }
  })

;

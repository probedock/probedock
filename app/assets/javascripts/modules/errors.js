angular.module('probedock.errors', [ 'ui.bootstrap' ])

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

  .service('errors', function($log, $modal) {
    var service = {
      showXhrErrors: function($scope, xhr) {

        var errors = [];
        try {
          errors = JSON.parse(xhr.responseText).errors;
        } catch(e) {
          $log.warn('Error response from server is malformed');
        }

        return service.showServerErrors($scope, xhr.status, xhr.statusText, errors);
      },

      showServerErrors: function($scope, statusCode, statusText, errors) {

        var scope = $scope.$new();
        _.extend(scope, {
          statusCode: statusCode,
          statusText: statusText,
          errors: errors
        });

        return $modal.open({
          scope: scope,
          templateUrl: '/templates/server-errors-modal.html'
        });
      }
    };

    return service;
  })

;

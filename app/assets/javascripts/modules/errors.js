angular.module('probedock.errors', [ 'ui.bootstrap' ])

  /**
   * Controller of the global error page for not found or authorization errors.
   */
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

  /**
   * Error handling service. Can be used to show a dialog detailing a server error.
   */
  .service('errors', function($log, $modal) {
    var service = {

      /**
       * Displays a modal dialog detailing the server error in the specified jQuery AJAX object.
       *
       * The response body is expected to be a JSON object with an `errors` property containing
       * an array of error objects. If that is not the case, only the status code and text will
       * be shown in the modal.
       */
      showXhrErrors: function($scope, xhr) {

        var errors = [];
        try {
          errors = JSON.parse(xhr.responseText).errors;
        } catch(e) {
          $log.warn('Error response from server is malformed');
        }

        return service.showServerErrors($scope, xhr.status, xhr.statusText, errors);
      },

      /**
       * Displays a modal dialog detailing the specified server error.
       * The `errors` argument must be a list of error objects that have already been
       * parsed from the server response.
       */
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

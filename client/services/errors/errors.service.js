/**
 * Error handling service. Can be used to show a dialog detailing a server error.
 */
angular.module('probedock.errors').service('errors', function($log, $uibModal) {
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

      return $uibModal.open({
        scope: scope,
        templateUrl: '/templates/services/errors/errors.modal.template.html'
      });
    }
  };

  return service;
});

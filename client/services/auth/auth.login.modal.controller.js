angular.module('probedock.auth').controller('LoginModalCtrl', function(auth, $http, $scope, $location, $uibModalInstance) {

  $scope.credentials = {};

  $scope.signIn = function() {
    delete $scope.error;
    auth.signIn($scope.credentials).then($scope.$close, showError);
  };

  $scope.getEmailUrl = function() {
    return ('mailto:support@probedock.io?' +
      // Build subject
      'subject=Please reset my password on ' + $location.host() +
      // Build body
      '&body=Dear Probe Dock Team,%0A%0A' +
      'Could you please reset my password on ' + $location.host() + '?' +
      (!_.isUndefined($scope.credentials.username) ? ' My user name is: ' + $scope.credentials.username : '') +
      '.%0A%0AThanks!').replace(' ', '%20');
  };

  $scope.$on('$stateChangeSuccess', function() {
    $uibModalInstance.dismiss('stateChange');
  });

  function showError() {
    $scope.error = true;
  }
});

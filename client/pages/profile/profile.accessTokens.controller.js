angular.module('probedock.profilePage').controller('ProfileAccessTokensCtrl', function(api, $scope) {

  $scope.busy = false;

  $scope.generate = function() {

    $scope.busy = true;
    delete $scope.token;

    api({
      method: 'POST',
      url: '/tokens'
    }).then(showToken, onGenerateError);
  };

  function onGenerateError() {
    delete $scope.token;
    $scope.generateError = true;
    $scope.busy = false;
  }

  function showToken(response) {
    $scope.token = response.data.token;
    $scope.busy = false;
  }
});

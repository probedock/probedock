angular.module('probe-dock.profile', ['probe-dock.api', 'probe-dock.auth'])

  .controller('ProfileAccessTokensCtrl', ['ApiService', '$scope', function($api, $scope) {

    $scope.busy = false;

    $scope.generate = function() {

      $scope.busy = true;
      delete $scope.token;

      $api.http({
        method: 'POST',
        url: '/api/tokens'
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
  }])

  .controller('ProfileDetailsCtrl', ['ApiService', 'AuthService', '$scope', function($api, $auth, $scope) {

    var modal;
    $scope.edit = function() {
      delete $scope.saveError;
      $scope.editedProfile = _.pick($auth.currentUser, 'name', 'email');
    };

    $scope.cancel = function() {
      delete $scope.editedProfile;
    };

    $scope.save = function() {
      $api.http({
        method: 'PATCH',
        url: '/api/users/' + $auth.currentUser.id,
        data: $api.compact($scope.editedProfile)
      }).then(onSaved, onSaveError);
    };

    function onSaveError() {
      $scope.saveError = true;
    }

    function onSaved(response) {
      delete $scope.editedProfile;
      _.extend($auth.currentUser, response.data);
    }
  }])

;

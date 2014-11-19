angular.module('rox.profile', ['rox.api', 'rox.auth'])

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

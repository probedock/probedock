angular.module('rox.profile', ['rox.api', 'rox.auth'])

  .controller('ProfileCtrl', ['ApiService', 'AuthService', '$modal', '$scope', function($api, $auth, $modal, $scope) {

    var modal;
    $scope.editProfile = function() {

      delete $scope.saveError;
      $scope.profile = _.pick($auth.currentUser, 'name', 'email');

      modal = $modal.open({
        templateUrl: '/templates/editProfile.html',
        scope: $scope
      });
    };

    $scope.save = function() {
      $api.http({
        method: 'PATCH',
        url: '/api/users/' + $auth.currentUser.id,
        data: $api.compact($scope.profile)
      }).then(onSaved, onSaveError);
    };

    function onSaveError() {
      $scope.saveError = true;
    }

    function onSaved(response) {
      _.extend($auth.currentUser, response.data);
      modal.close(response.data);
    }
  }])

;

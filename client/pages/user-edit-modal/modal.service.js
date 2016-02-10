angular.module('probedock.userEditModal').factory('userEditModal', function($modal) {
  return {
    open: function($scope) {

      var modal = $modal.open({
        templateUrl: '/templates/pages/user-edit-modal/modal.template.html',
        controller: 'UserEditModalCtrl',
        scope: $scope
      });

      $scope.$on('$stateChangeStart', function() {
        modal.dismiss('stateChange');
      });

      return modal;
    }
  };
}).controller('UserEditModalCtrl', function(forms, $modalInstance, $scope, users) {

  $scope.editedUser = angular.copy($scope.user);

  $scope.changed = function() {
    return !forms.dataEquals($scope.user, $scope.editedUser);
  };

  $scope.save = function() {
    users.updateUser($scope.editedUser).then($modalInstance.close);
  };
});

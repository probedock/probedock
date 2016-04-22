angular.module('probedock.userEditModal').factory('userEditModal', function(states, $uibModal) {
  return {
    open: function($scope) {

      var modal = $uibModal.open({
        templateUrl: '/templates/pages/user-edit-modal/modal.template.html',
        controller: 'UserEditModalCtrl',
        scope: $scope
      });

      states.onStateChangeStart($scope, true, function() {
        modal.dismiss('stateChange');
      });

      return modal;
    }
  };
}).controller('UserEditModalCtrl', function(forms, $scope, $uibModalInstance, users) {

  $scope.editedUser = angular.copy($scope.user);

  $scope.changed = function() {
    return !forms.dataEquals($scope.user, $scope.editedUser);
  };

  $scope.save = function() {
    users.updateUser($scope.editedUser).then($uibModalInstance.close);
  };
});

angular.module('probedock.userDetailsWidget').directive('userDetailsWidget', function() {
  return {
    restrict: 'E',
    controller: 'UserDetailsWidgetCtrl',
    templateUrl: '/templates/widgets/user-details/details.template.html',
    scope: {
      user: '=',
      mode: '@'
    }
  };
}).controller('UserDetailsWidgetCtrl', function($scope, $state, $stateParams, states, userEditModal) {

  $scope.edit = function() {
    if ($scope.mode == 'profile') {
      $state.go('profile.edit');
    } else {
      $state.go('admin.users.show.edit', { id: $stateParams.id });
    }
  };

  states.onState($scope, /\.edit$/, function() {
    modal = userEditModal.open($scope);

    modal.result.then(function(user) {
      $state.go('^', {}, { inherit: true });
    }, function(reason) {
      if (reason != 'stateChange') {
        $state.go('^', {}, { inherit: true });
      }
    });
  });
});

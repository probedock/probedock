angular.module('probedock.memberRegistrationPage').controller('NewUserMemberRegistrationModalCtrl', function(api, auth, $modalInstance, $scope, $state, $stateParams) {

  $scope.user = {
    primaryEmail: $scope.membership.organizationEmail
  };

  $scope.newUser = angular.copy($scope.user);

  $scope.register = function() {
    register().then(autoSignIn).then(function() {
      $modalInstance.dismiss();
      $state.go('org.dashboard.default', { orgName: $scope.membership.organization.name });
    });
  };

  $scope.$on('$stateChangeSuccess', function() {
    $modalInstance.dismiss('stateChange');
  });

  function register() {
    return api({
      method: 'POST',
      url: '/users',
      params: {
        membershipOtp: $stateParams.otp
      },
      data: $scope.newUser
    });
  }

  function autoSignIn() {
    return auth.signIn({
      username: $scope.newUser.name,
      password: $scope.newUser.password
    });
  }
});

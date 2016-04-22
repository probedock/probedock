angular.module('probedock.memberRegistrationPage').controller('NewUserMemberRegistrationModalCtrl', function(api, auth, $scope, $state, $stateParams, states, $uibModalInstance) {

  $scope.user = {
    primaryEmail: $scope.membership.organizationEmail
  };

  $scope.newUser = angular.copy($scope.user);

  $scope.register = function() {
    register().then(autoSignIn).then(function() {
      $uibModalInstance.dismiss();
      $state.go('org.dashboard.default', { orgName: $scope.membership.organization.name });
    });
  };

  states.onStateChangeStart($scope, true, function() {
    $uibModalInstance.dismiss('stateChange');
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

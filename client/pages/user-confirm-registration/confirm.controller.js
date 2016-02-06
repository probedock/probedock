angular.module('probedock.userConfirmRegistrationPage').controller('UserConfirmRegistrationPageCtrl', function(api, auth, $scope, $state, $stateParams) {

  $scope.confirmRegistration = confirmRegistration;

  api({
    url: '/registrations',
    params: {
      otp: $stateParams.otp
    }
  }).then(function(res) {
    if (!res.data.length) {
      $state.go('error', { type: 'notFound' });
    } else {
      $scope.registration = res.data[0];
    }
  });

  function confirmRegistration() {
    updateUser().then(signIn).then(goToOrg);
  }

  function updateUser() {

    var data = _.pick($scope.registration.user, 'password', 'passwordConfirmation');
    data.active = true;

    return api({
      method: 'PATCH',
      url: '/users/' + $scope.registration.user.id,
      data: data,
      params: {
        registrationOtp: $stateParams.otp
      }
    });
  };

  function signIn() {
    return auth.signIn({ username: $scope.registration.user.name, password: $scope.registration.user.password });
  }

  function goToOrg() {
    $state.go('org.dashboard.default', { orgName: $scope.registration.organization.name });
  }
});

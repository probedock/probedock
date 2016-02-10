angular.module('probedock.memberRegistrationPage').controller('MemberRegistrationPageCtrl', function(api, auth, $modal, orgs, $q, $scope, $state, $stateParams) {

  api({
    url: '/memberships',
    params: {
      otp: $stateParams.otp,
      withOrganization: 1
    }
  }).then(function(res) {

    $scope.membership = res.data.length ? res.data[0] : null;
    $scope.invalidOtp = !res.data.length;

    if (!$scope.membership) {
      return;
    }

    if (auth.currentUser) {
      checkExistingMembership();
    } else {
      $scope.$on('auth.signIn', checkExistingMembership);
    }
  }, function(err) {
    if (err.status == 403) {
      $scope.invalidOtp = true;
    }
  });

  $scope.$on('auth.signOut', function() {
    delete $scope.existingMembership;
  });

  $scope.openSignInDialog = auth.openSignInDialog;

  $scope.emailIsNew = function() {
    return !_.some(auth.currentUser.emails, function(email) {
      return email.address == $scope.membership.organizationEmail;
    });
  };

  $scope.openRegistrationDialog = function() {
    $modal.open({
      scope: $scope,
      controller: 'NewUserMemberRegistrationModalCtrl',
      templateUrl: '/templates/pages/member-registration/registration.newUser.template.html'
    });
  };

  $scope.accept = function() {
    api({
      method: 'PATCH',
      url: '/memberships/' + $scope.membership.id,
      params: {
        otp: $stateParams.otp
      },
      data: {
        userId: auth.currentUser.id
      }
    }).then(function() {

      var promise = $q.when();

      if (!$scope.membership.organization.public) {
        promise = promise.then(orgs.refreshOrgs);
      }

      promise.then(function() {
        $state.go('org.dashboard.default', { orgName: $scope.membership.organization.name });
      });
    });
  };

  function checkExistingMembership() {
    api({
      url: '/memberships',
      params: {
        mine: 1,
        organizationId: $scope.membership.organizationId
      },
      custom: {
        ignoreForbidden: true
      }
    }).then(function(res) {
      $scope.existingMembership = res.data.length ? res.data[0] : null;
    });
  }
});

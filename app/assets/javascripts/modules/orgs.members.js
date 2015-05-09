angular.module('probe-dock.orgs.members', [ 'probe-dock.api' ])

  .factory('orgMembers', function(api, $modal, $rootScope) {

    var service = {
      openForm: function($scope) {

        var modal = $modal.open({
          templateUrl: '/templates/org-member-modal.html',
          controller: 'OrgMemberModalCtrl',
          scope: $scope
        });

        $rootScope.$on('$stateChangeSuccess', function() {
          modal.dismiss('stateChange');
        });

        return modal;
      }
    };

    return service;
  })

  .controller('OrgMembersCtrl', function(api, orgMembers, orgs, $scope, $state, $stateParams) {

    $scope.memberships = [];
    fetchMemberships();

    $scope.organizationRoles = [ 'admin' ];

    $scope.$on('$stateChangeSuccess', function(event, toState) {
      if (toState.name.match(/^org\.dashboard\.members\.(?:new|edit)$/)) {

        var modal = orgMembers.openForm($scope);

        modal.result.then(function(membership) {
          api.pushOrUpdate($scope.memberships, membership);
          orgs.updateOrganization(_.extend(orgs.currentOrganization, { membershipsCount: orgs.currentOrganization.membershipsCount + 1 }));
          $state.go('^', {}, { inherit: true });
        }, function(reason) {
          if (reason != 'stateChange') {
            $state.go('^', {}, { inherit: true });
          }
        });
      }
    });

    $scope.remove = function(membership) {

      var message = "Are you sure you want to remove ";
      message += membership.user ? membership.user.name : membership.organizationEmail;
      message += "'s membership?";

      if (!confirm(message)) {
        return;
      }

      api({
        method: 'DELETE',
        url: '/memberships/' + membership.id
      }).then(function() {
        $scope.memberships.splice($scope.memberships.indexOf(membership), 1);
        orgs.updateOrganization(_.extend(orgs.currentOrganization, { membershipsCount: orgs.currentOrganization.membershipsCount - 1 }));
      });
    };

    function fetchMemberships(page) {
      page = page || 1;

      api({
        url: '/memberships',
        params: {
          organizationName: $stateParams.orgName,
          withUser: 1,
          pageSize: 25,
          page: page
        }
      }).then(function(res) {
        $scope.memberships = $scope.memberships.concat(res.data);
        // FIXME: use pagination to determine if more records are available
        if (res.data.length == 25) {
          fetchMemberships(++page);
        }
      });
    }
  })

  // TODO: display message if user is aleady a member
  .controller('OrgMemberModalCtrl', function(api, forms, $modalInstance, orgs, $scope, $stateParams) {

    orgs.forwardData($scope);

    $scope.membership = {
      organizationId: $scope.currentOrganization.id
    };

    reset();

    if ($stateParams.id) {
      api({
        url: '/memberships/' + $stateParams.id,
        params: {
          withUser: 1
        }
      }).then(function(res) {
        $scope.membership = res.data;
        reset();
      });
    }

    $scope.reset = reset;
    $scope.changed = function() {
      return !forms.dataEquals($scope.membership, $scope.editedMembership);
    };

    $scope.save = function() {

      var method = 'POST',
          url = '/memberships';

      if ($scope.membership.id) {
        method = 'PATCH';
        url += '/' + $scope.membership.id;
      }

      api({
        method: method,
        url: url,
        data: $scope.editedMembership
      }).then(function(res) {
        $modalInstance.close(res.data);
      });
    };

    function reset() {
      $scope.editedMembership = angular.copy($scope.membership);
    }
  })

  .controller('NewMembershipCtrl', function(api, auth, $modal, $scope, $state, $stateParams) {

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
        controller: 'NewMembershipRegistrationCtrl',
        templateUrl: '/templates/new-membership-register-modal.html'
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
        $state.go('org.dashboard.default', { orgName: $scope.membership.organization.name });
      });
    };

    function checkExistingMembership() {
      api({
        url: '/memberships',
        params: {
          mine: 1,
          organizationId: $scope.membership.organizationId
        }
      }).then(function(res) {
        $scope.existingMembership = res.data.length ? res.data[0] : null;
      });
    }
  })

  .controller('NewMembershipRegistrationCtrl', function(api, auth, $modalInstance, $scope, $state, $stateParams) {

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
  })

;

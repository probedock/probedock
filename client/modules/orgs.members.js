angular.module('probedock.orgs.members', [ 'probedock.api' ])

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

    $scope.removeMembership = removeMembership;
    $scope.updateMembership = updateMembership;

    $scope.humanMemberships = function() {
      return _.filter($scope.memberships, function(membership) {
        return !membership.user || !membership.user.technical;
      });
    };

    $scope.technicalMemberships = function() {
      return _.filter($scope.memberships, function(membership) {
        return membership.user && membership.user.technical;
      });
    };

    fetchMemberships();

    $scope.$on('$stateChangeSuccess', function(event, toState) {
      if (toState.name.match(/^org\.dashboard\.members\.(?:new|edit)$/)) {

        var modal = orgMembers.openForm($scope);

        modal.result.then(function(membership) {
          updateMembership(membership);
          $state.go('^', {}, { inherit: true });
        }, function(reason) {
          if (reason != 'stateChange') {
            $state.go('^', {}, { inherit: true });
          }
        });
      }
    });

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
        if (res.pagination().hasMorePages) {
          fetchMemberships(++page);
        }
      });
    }

    function updateMembership(membership) {
      var n = api.pushOrUpdate($scope.memberships, membership);
      orgs.updateOrganization(_.extend(orgs.currentOrganization, { membershipsCount: orgs.currentOrganization.membershipsCount + n }));
    }

    function removeMembership(membership) {
      $scope.memberships.splice($scope.memberships.indexOf(membership), 1);
      orgs.updateOrganization(_.extend(orgs.currentOrganization, { membershipsCount: orgs.currentOrganization.membershipsCount - 1 }));
    }
  })

  .directive('orgMemberPanel', function() {
    return {
      restrict: 'E',
      templateUrl: '/templates/org-member-panel.html',
      controller: 'OrgMemberPanelCtrl',
      scope: {
        membership: '=',
        onDelete: '&'
      }
    };
  })

  .controller('OrgMemberPanelCtrl', function(api, orgs, $scope) {

    orgs.addAuthFunctions($scope);

    $scope.generateAccessToken = generateAccessToken;
    $scope.remove = deleteMembership;

    function generateAccessToken() {
      api({
        method: 'POST',
        url: '/tokens',
        data: {
          userId: $scope.membership.user.id
        }
      }).then(function(res) {
        $scope.accessToken = res.data.token;
      });
    }

    function deleteMembership() {

      var membership = $scope.membership;

      var message;
      if (membership.user && membership.user.technical) {
        message = "Are you sure you want to delete technical user " + membership.user.name + '?';
      } else {
        message = "Are you sure you want to remove ";
        message += membership.user ? membership.user.name : membership.organizationEmail;
        message += "'s membership?";
      }

      if (!confirm(message)) {
        return;
      }

      var promise;
      if (membership.user && membership.user.technical) {
        promise = deleteTechnicalUser();
      } else {
        promise = deleteMembership();
      }

      promise.then(function() {
        $scope.onDelete();
      });

      function deleteMembership() {
        return api({
          method: 'DELETE',
          url: '/memberships/' + membership.id
        });
      }

      function deleteTechnicalUser() {
        return api({
          method: 'DELETE',
          url: '/users/' + membership.user.id
        });
      }
    };
  })

  // TODO: display message if user is aleady a member
  .controller('OrgMemberModalCtrl', function(api, forms, $modalInstance, orgs, $scope, $stateParams) {

    orgs.forwardData($scope);

    $scope.organizationRoles = [ 'admin' ];

    $scope.settings = {
      technicalUser: false
    };

    $scope.membership = {
      organizationId: $scope.currentOrganization.id
    };

    $scope.user = {
      technical: true,
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

        if (res.data.user.technical) {
          $scope.settings.technicalUser = true;
          _.defaults($scope.user, res.data.user);
        }

        reset();
      });
    }

    $scope.reset = reset;

    $scope.changed = function() {
      if ($scope.settings.technicalUser) {
        return !forms.dataEquals($scope.user, $scope.technicalUser);
      } else {
        return !forms.dataEquals($scope.membership, $scope.editedMembership);
      }
    };

    $scope.save = function() {
      var promise;

      if ($scope.settings.technicalUser && $scope.user.id) {
        promise = updateTechnicalUser();
      } else if ($scope.settings.technicalUser) {
        promise = createTechnicalUser();
      } else if ($scope.membership.id) {
        promise = updateMembership();
      } else {
        promise = createMembershipembership();
      }

      promise.then(function(membership) {
        $modalInstance.close(membership);
      });
    };

    function createTechnicalUser() {
      return api({
        method: 'POST',
        url: '/users',
        params: {
          withTechnicalMembership: 1
        },
        data: $scope.technicalUser
      }).then(function(res) {
        return _.extend(res.data.technicalMembership, {
          user: _.omit(res.data, 'technicalMembership')
        });
      });
    }

    function updateTechnicalUser() {
      return api({
        method: 'PATCH',
        url: '/users/' + $scope.user.id,
        params: {
          withTechnicalMembership: 1
        },
        data: $scope.technicalUser
      }).then(function(res) {
        return _.extend(res.data.technicalMembership, {
          user: _.omit(res.data, 'technicalMembership')
        });
      });
    }

    function createMembershipembership() {
      return api({
        method: 'POST',
        url: '/memberships',
        data: $scope.editedMembership
      }).then(function(res) {
        return res.data;
      });
    }

    function updateMembership() {
      return api({
        method: 'PATCH',
        url: '/memberships/' + $scope.membership.id,
        params: {
          withUser: 1
        },
        data: $scope.editedMembership
      }).then(function(res) {
        return res.data;
      });
    }

    function reset() {
      $scope.editedMembership = angular.copy($scope.membership);
      $scope.technicalUser = angular.copy($scope.user);
    }
  })

  .controller('NewMembershipCtrl', function(api, auth, $modal, orgs, $q, $scope, $state, $stateParams) {

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

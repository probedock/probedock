angular.module('probedock.memberEditModal').factory('memberEditModal', function(api, states, $uibModal) {
  return {
    open: function($scope) {

      var modal = $uibModal.open({
        controller: 'MemberEditModalCtrl',
        templateUrl: '/templates/pages/member-edit-modal/modal.template.html',
        scope: $scope
      });

      states.onStateChangeStart($scope, true, function() {
        modal.dismiss('stateChange');
      });

      return modal;
    }
  };
}).controller('MemberEditModalCtrl', function(api, forms, orgs, $scope, $stateParams, $uibModalInstance) {
  // TODO: display message if user is aleady a member

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
      $uibModalInstance.close(membership);
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
});

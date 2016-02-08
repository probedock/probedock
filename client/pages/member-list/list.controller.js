angular.module('probedock.memberListPage').controller('MemberListPageCtrl', function(api, memberEditModal, orgs, $scope, $state, $stateParams) {

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

      var modal = memberEditModal.open($scope);

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
});

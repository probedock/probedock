angular.module('probedock.homePage').controller('HomePageCtrl', function(orgEditModal, orgs, $scope, $state) {
  orgs.forwardData($scope);

  $scope.$on('$stateChangeSuccess', function(even, toState) {
    if (toState.name == 'home.newOrg') {
      var modal = orgEditModal.open($scope);

      modal.result.then(function(org) {
        $state.go('org.dashboard.members', { orgName: org.name });
      }, function(reason) {
        if (reason != 'stateChange') {
          $state.go('^', {}, { inherit: true });
        }
      });
    }
  });

  $scope.orderOrganization = function(org) {
    return (org.displayName || org.name).toLowerCase();
  };
});

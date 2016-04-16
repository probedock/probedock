angular.module('probedock.homePage').controller('HomePageCtrl', function(orgEditModal, orgs, $scope, $state, states) {
  orgs.forwardData($scope);

  states.onState($scope, 'home.newOrg', function() {
    var modal = orgEditModal.open($scope);

    modal.result.then(function(org) {
      $state.go('org.dashboard.members', { orgName: org.name });
    }, function(reason) {
      if (reason != 'stateChange') {
        $state.go('^', {}, { inherit: true });
      }
    });
  });

  $scope.orderOrganization = function(org) {
    return (org.displayName || org.name).toLowerCase();
  };
});

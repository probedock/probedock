angular.module('probedock.dashboardPage').controller('DashboardHeaderCtrl', function(orgEditModal, $scope, $state, states) {

  states.onStateChangeSuccess($scope, 'org.dashboard.default.edit', function(state, params, resolves) {

    var modal = orgEditModal.open($scope, {
      organizationName: resolves.routeOrgName
    });

    modal.result.then(function() {
      $state.go('^', {}, { inherit: true });
    }, function(reason) {
      if (reason != 'stateChange') {
        $state.go('^', {}, { inherit: true });
      }
    });
  });
});

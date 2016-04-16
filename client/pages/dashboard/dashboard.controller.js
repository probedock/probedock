angular.module('probedock.dashboardPage').controller('DashboardPageCtrl', function(api, orgs, routeOrgName, $scope) {
  orgs.forwardData($scope);

  $scope.orgIsActive = function() {
    return $scope.currentOrganization && $scope.currentOrganization.projectsCount && $scope.currentOrganization.membershipsCount;
  };

  $scope.gettingStarted = false;

  api({
    url: '/reports',
    params: {
      pageSize: 1,
      organizationName: routeOrgName
    }
  }).then(function(res) {
    if (!res.pagination().total) {
      $scope.gettingStarted = true;
    }
  });
});

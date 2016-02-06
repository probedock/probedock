angular.module('probedock.recentActivityWidget').directive('recentActivityWidget', function() {
  return {
    restrict: 'E',
    controller: 'RecentActivityCtrl',
    controllerAs: 'ctrl',
    templateUrl: '/templates/widgets/recent-activity/activity.template.html',
    scope: {
      organization: '='
    }
  };
}).controller('RecentActivityCtrl', function(api, $scope) {

  $scope.$watch('organization', function(value) {
    if (value) {
      fetchReports();
    }
  });

  function fetchReports() {
    return api({
      url: '/reports',
      params: {
        pageSize: 5,
        organizationId: $scope.organization.id,
        withRunners: 1,
        withProjects: 1,
        withProjectVersions: 1,
        withCategories: 1
      }
    }).then(showReports);
  }

  function showReports(response) {
    $scope.reports = response.data;
  }
});

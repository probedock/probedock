angular.module('probedock.recentActivityWidget').directive('recentActivityWidget', function() {
  return {
    restrict: 'E',
    controller: 'RecentActivityWidgetCtrl',
    controllerAs: 'ctrl',
    templateUrl: '/templates/widgets/recent-activity/activity.template.html',
    scope: {
      organization: '=',
      project: '=?',
      linkToVersion: '=?'
    }
  };
}).controller('RecentActivityWidgetCtrl', function(api, $scope) {

  _.defaults($scope, {
    linkToVersion: true
  });

  $scope.$watch('organization', function(value) {
    if (value) {
      fetchReports();
    }
  });

  $scope.getNewTestsCount = function(report) {
    if ($scope.project) {
      return report.projectCounts.newTestsCount;
    } else {
      return report.newTestsCount;
    }
  };

  function fetchReports() {

    var params = {};
    if ($scope.project) {
      params.projectId = $scope.project.id;
      params.withProjectCountsFor = $scope.project.id;
    } else {
      params.organizationId = $scope.organization.id;
    }

    return api({
      url: '/reports',
      params: _.extend(params, {
        pageSize: 5,
        withRunners: 1,
        withProjects: 1,
        withProjectVersions: 1,
        withCategories: 1
      })
    }).then(showReports);
  }

  function showReports(response) {
    $scope.reports = response.data;
  }
});

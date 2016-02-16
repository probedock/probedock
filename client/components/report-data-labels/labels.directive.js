angular.module('probedock.reportDataLabels').directive('reportDataLabels', function() {
  return {
    restrict: 'E',
    controller: 'ReportDataLabelsCtrl',
    templateUrl: '/templates/components/report-data-labels/report-data-labels.template.html',
    replace: true,
    scope: {
      report: '=',
      organization: '=',
      nbProjectsToShow: '=?',
      projectFilter: '=?',
      showVersionsOnly: '=?'
    }
  };
})
.controller('ReportDataLabelsCtrl', function($scope) {
  if (!$scope.nbProjectsToShow) {
    $scope.nbProjectsToShow = 5;
  }

  if (!$scope.showVersionsOnly) {
    $scope.showVersionsOnly = false;
  }

  $scope.filteredProjects = $scope.projectFilter ? _.where($scope.report.projects, { id: $scope.projectFilter.id }) : $scope.report.projects;
  $scope.projects = $scope.filteredProjects.slice(0, $scope.nbProjectsToShow);

  $scope.hasMore = function() {
    return $scope.report.projects.length > $scope.projects.length;
  };

  $scope.showMore = function() {
    $scope.projects = $scope.report.projects;
    $scope.showVersionsOnly = false;
  };
});

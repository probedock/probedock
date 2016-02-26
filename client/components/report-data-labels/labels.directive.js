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
      forProject: '=?',
      versionsOnly: '=?'
    }
  };
})
.controller('ReportDataLabelsCtrl', function($scope) {
  if (!$scope.nbProjectsToShow) {
    $scope.nbProjectsToShow = 5;
  }

  if (!$scope.versionsOnly) {
    $scope.versionsOnly = false;
  }

  var filteredProjects = $scope.forProject ? _.where($scope.report.projects, { id: $scope.forProject.id }) : $scope.report.projects;
  $scope.projects = filteredProjects.slice(0, $scope.nbProjectsToShow);

  $scope.hasMore = function() {
    return $scope.report.projects.length > $scope.projects.length;
  };

  $scope.showMore = function() {
    $scope.projects = $scope.report.projects;
    $scope.versionsOnly = false;
  };
});

angular.module('probedock.projectDetailsWidget').directive('projectDetailsWidget', function() {
  return {
    restrict: 'E',
    controller: 'ProjectDetailsWidgetCtrl',
    templateUrl: '/templates/widgets/project-details/details.template.html',
    scope: {
      organization: '=',
      project: '='
    }
  };
}).controller('ProjectDetailsWidgetCtrl', function(api, orgs, $scope) {
  orgs.addAuthFunctions($scope);

  if ($scope.project && $scope.project.lastReportId) {
    fetchReport();
  }

  function fetchReport() {
    return api({
      url: '/reports/' + $scope.project.lastReportId,
      params: {
        withProjectCountsFor: $scope.project.id
      }
    }).then(function(res) {
      return showChart(res.data);
    });
  }

  function showChart(report) {

    var numberPassed = report.projectCounts.passedResultsCount - report.projectCounts.inactivePassedResultsCount,
        numberInactive = report.projectCounts.inactiveResultsCount,
        numberFailed = report.projectCounts.resultsCount - numberPassed - numberInactive;

    $scope.stateChart = {
      labels: [ 'passed', 'failed', 'inactive' ],
      data: [ numberPassed, numberFailed, numberInactive ],
      colors: [ '#62c462', '#ee5f5b', '#fbb450' ]
    };
  }
});

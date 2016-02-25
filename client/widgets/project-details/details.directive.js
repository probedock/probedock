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
    //fetchReport();
    fetchOldestTechnicalUser();
  }

  function fetchOldestTechnicalUser() {
    return api({
      url: '/users',
      params: {
        sort: 'createdAt',
        technical: true,
        pageSize: 1,
        page: 1
      }
    }).then(function(res) {
      if (res.data.length == 1) {
        $scope.technicalUser = res.data[0];
        fetchReportByTechnicalUser();
      }
      else {
        fetchReport();
      }
    });
  }

  function fetchReportByTechnicalUser() {
    return api({
      url: '/reports/',
      params: {
        withProjectCountsFor: $scope.project.id,
        organizationId: $scope.organization.id,
        runnerId: $scope.technicalUser.id,
        pageSize: 1,
        page: 1
      }
    }).then(function(res) {
      if (res.data.lenght == 1) {
        return showChart(res.data);
      }
      else {
        $scope.technicalUser = null;
        return fetchReport();
      }
    });
  }

  function fetchReport() {
    return api({
      url: '/reports/' + $scope.project.lastReportId,
      params: {
        withProjectCountsFor: $scope.project.id
      }
    }).then(function(res) {
      $scope.runners = res.data.runners;
      return showChart(res.data);
    });
  }

  function showChart(report) {
    $scope.report = report;

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

angular.module('probedock.reportDetailsPage').directive('reportDetails', function() {
  return {
    restrict: 'E',
    controller: 'ReportDetailsCtrl',
    templateUrl: '/templates/pages/report-details/details.template.html',
    scope: {
      report: '=',
      organization: '='
    }
  };
}).controller('ReportDetailsCtrl', function(api, $scope) {
  $scope.reportFilters = {
    showPassed: true,
    showFailed: true,
    showInactive: true,
    showExisting: true,
    showNew: true,
    categories: [],
    tags: [],
    tickets: []
  };

  $scope.hasFilters = function() {
    var f = $scope.reportFilters;

    var result =
      !f.showPassed ||
      !f.showFailed ||
      !f.showInactive ||
      !f.showExisting ||
      !f.showNew ||
      (!!f.name && !!f.name.length) ||
      !!f.categories.length ||
      !!f.tags.length ||
      !!f.tickets.length;

    return result;
  };

  $scope.$watch('reportFilters', function(value) {
    if (value && $scope.report) {
      $scope.$broadcast('report.filtersChanged', value);
    }
  }, true);

  $scope.$watch('report', function(report) {
    if (report) {
      showReport(report);
    }
  });

  function showReport(report) {

    $scope.report = report;

    var numberPassed = report.passedResultsCount - report.inactivePassedResultsCount,
        numberInactive = report.inactiveResultsCount,
        numberFailed = report.resultsCount - numberPassed - numberInactive;

    $scope.healthChart = {
      labels: [ 'passed', 'failed', 'inactive' ],
      data: [ numberPassed, numberFailed, numberInactive ],
      colors: [ '#62c462', '#ee5f5b', '#fbb450' ]
    };
  }
});

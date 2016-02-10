angular.module('probedock.reportHealthBar').directive('reportHealthBar', function() {
  return {
    restrict: 'E',
    controller: 'ReportHealthBarCtrl',
    templateUrl: '/templates/components/report-health-bar/bar.template.html',
    scope: {
      report: '=',
      clickForDetails: '@'
    }
  };
}).controller('ReportHealthBarCtrl', function($attrs, reports, $scope) {

  $scope.percentages = reports.percentages($scope.report);
  $scope.tooltipText = tooltipText($scope.report, $attrs.clickForDetails !== undefined);

  function tooltipText(report, clickForDetails) {

      var tooltipText = [],
          numberPassed = report.passedResultsCount - report.inactivePassedResultsCount,
          numberInactive = report.inactiveResultsCount,
          numberFailed = report.resultsCount - numberPassed - numberInactive;

      if (numberPassed) {
        tooltipText.push(numberPassed + ' passed');
      }
      if (numberFailed) {
        tooltipText.push(numberFailed + ' failed');
      }
      if (numberInactive) {
        tooltipText.push(numberInactive + ' inactive');
      }

      tooltipText = tooltipText.join(', ');
      if (clickForDetails) {
        tooltipText += '. Click to see the detailed report.';
      }

      return tooltipText;
  }
});

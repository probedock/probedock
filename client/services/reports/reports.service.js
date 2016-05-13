angular.module('probedock.reports').factory('reports', function() {
  return {
    percentages: function(report) {

      var passed = (report.passedResultsCount - report.inactivePassedResultsCount) * 100.0 / report.resultsCount,
          inactive = report.inactiveResultsCount * 100.0 / report.resultsCount;

      if (passed + inactive > 100.0) {
        inactive = 100.0 - passed;
      }

      return percentages = {
        passed: passed,
        inactive: inactive,
        failed: 100.0 - passed - inactive
      };
    }
  };
});

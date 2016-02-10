angular.module('probedock.reports').factory('reports', function() {
  return {
    percentages: function(report) {

      var passed = Math.round((report.passedResultsCount - report.inactivePassedResultsCount) * 100 / report.resultsCount),
          inactive = Math.round(report.inactiveResultsCount * 100 / report.resultsCount);

      if (passed + inactive > 100) {
        inactive = 100 - passed;
      }

      return percentages = {
        passed: passed,
        inactive: inactive,
        failed: 100 - passed - inactive
      };
    }
  };
});

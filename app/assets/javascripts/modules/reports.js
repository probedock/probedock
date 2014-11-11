angular.module('rox.reports', ['rox.api'])

  .controller('ReportController', ['ApiService', '$scope', '$stateParams', function($api, $scope, $stateParams) {

    fetchReport();

    function fetchReport() {
      $api.http({
        method: 'GET',
        url: '/api/reports/' + $stateParams.reportId
      }).then(showReport);
    }

    function showReport(response) {
      $scope.report = response.data;
    }
  }])

  .controller('ReportsController', ['ApiService', '$scope', function($api, $scope) {

    $scope.fetchReports = function(params) {
      $api.http({
        method: 'GET',
        url: '/api/reports',
        params: {
          pageSize: 10,
          'sort[]': [ 'createdAt desc' ]
        }
      }).then(showReports);
    };

    $scope.fetchReports();

    function showReports(response) {

      $scope.reports = response.data;

      _.each($scope.reports, function(report) {

        var passed = Math.round((report.passedResultsCount - report.inactivePassedResultsCount) * 100 / report.resultsCount),
            inactive = Math.round(report.inactiveResultsCount * 100 / report.resultsCount);

        if (passed + inactive > 100) {
          inactive = 100 - passed;
        }

        report.percentages = {
          passed: passed,
          inactive: inactive,
          failed: 100 - passed - inactive
        };
      });
    }
  }])

;

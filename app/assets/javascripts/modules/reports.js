angular.module('rox.reports', ['rox.api'])

  .controller('ReportsCtrl', ['$scope', 'StateService', function($scope, $stateService) {

    $scope.activeTabs = {
      latest: true,
      details: false
    };
    $scope.detailsTabReportId = null;

    $stateService.onState({ name: [ 'std.reports', 'std.reports.details' ] }, $scope, function(state, params) {
      if (state && state.name == 'std.reports.details') {
        showReportDetails(params.reportId);
      } else {
        $scope.activeTabs.latest = true;
        $scope.activeTabs.details = false;
      }
    });

    function showReportDetails(reportId) {
      $scope.activeTabs.latest = false;
      $scope.activeTabs.details = true;
      $scope.detailsTabReportId = reportId;
    };
  }])

  .controller('ReportDetailsCtrl', ['ApiService', 'ReportService', '$scope', 'StateService', function($api, $reportService, $scope, $stateService) {

    var reportId;
    $stateService.onState({ name: 'std.reports.details' }, $scope, function(state, params) {
      if (params.reportId != reportId) {
        delete $scope.report;
        reportId = params.reportId;
        fetchReport();
      }
    });

    function fetchReport() {
      $api.http({
        method: 'GET',
        url: '/api/reports/' + reportId
      }).then(showReport);
    }

    function showReport(response) {
      $scope.report = $reportService.enrichReports(response.data);
    }
  }])

  .controller('LatestReportsCtrl', ['ApiService', 'ReportService', '$scope', 'StateService', function($api, $reportService, $scope, $stateService) {

    $stateService.onState({ name: 'std.reports' }, $scope, function() {
      if ($scope.reports === undefined) {
        fetchReports();
      }
    });

    function fetchReports() {

      $scope.reports = false;

      $api.http({
        method: 'GET',
        url: '/api/reports',
        params: {
          pageSize: 10,
          'sort[]': [ 'createdAt desc' ]
        }
      }).then(showReports);
    };

    function showReports(response) {
      $scope.reports = $reportService.enrichReports(response.data);
    }
  }])

  .factory('ReportService', [function() {
    return {
      enrichReports: function(reports) {

        _.each(_.isArray(reports) ? reports : [ reports ], function(report) {

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

        return reports;
      }
    };
  }])

;

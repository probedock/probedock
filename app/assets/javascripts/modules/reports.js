angular.module('rox.reports', ['rox.api'])

  .controller('ReportResultsCtrl', ['ApiService', '$scope', function($api, $scope) {

    var page, pageSize, reportId;

    $scope.$on('report.init', init);

    $scope.showAllResults = function() {
      $scope.showingAllResults = true;
    };

    $scope.showMoreResults = function() {
      page++;
      fetchResults().then(addResults);
    };

    function init(event, newReportId) {

      page = 1;
      pageSize = 30;
      $scope.showingAllResults = false;
      $scope.fetchingMoreResults = false;
      $scope.noMoreResults = false;
      delete $scope.results;
      delete $scope.total;

      reportId = newReportId;
      fetchResults().then(addResults);
    }

    function fetchResults() {

      $scope.fetchingMoreResults = true;

      return $api.http({
        method: 'GET',
        url: '/api/reports/' + reportId + '/results',
        params: {
          page: page,
          pageSize: 30
        }
      });
    }

    function addResults(response) {

      $scope.fetchingMoreResults = false;
      $scope.total = response.headers('X-Pagination').match(/total=(\d+)/)[1];

      if (!$scope.results) {
        $scope.results = response.data;
      } else {
        $scope.results = $scope.results.concat(response.data);
      }

      $scope.noMoreResults = $scope.results.length >= $scope.total || !response.data.length;
    }
  }])

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
        $scope.$broadcast('report.init', reportId);

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

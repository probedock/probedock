angular.module('probe-dock.reports', ['ngSanitize', 'probe-dock.api', 'probe-dock.state'])

  .directive('reportHealthBar', [function() {

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

    return {
      restrict: 'E',
      scope: {
        report: '=',
        clickForDetails: '@'
      },
      controller: ['$attrs', 'ReportService', '$scope', function($attrs, $reportService, $scope) {
        $scope.percentages = $reportService.percentages($scope.report);
        $scope.tooltipText = tooltipText($scope.report, $attrs.clickForDetails !== undefined);
      }],
      templateUrl: '/templates/reportHealthBar.html'
    };
  }])

  .directive('healthTooltips', ['$compile', function ($compile) {
    return function(scope, element, attrs) {

      var titleTemplate = _.template('<strong class="<%= titleClass %>"><%- title %></strong>'),
          contentTemplate = _.template('<ul class="list-unstyled"><li><strong>Duration:</strong> <%- duration %></li></ul>');

      element.on('mouseenter', 'a', function() {

        var e = $(this);

        if (!e.data('bs.popover')) {

          var titleClass = 'text-success';

          if (e.is('.f')) {
            titleClass = 'text-danger';
          } else if (e.is('.i')) {
            titleClass = 'text-warning';
          }

          e.popover({
            trigger: 'hover manual',
            placement: 'auto',
            title: titleTemplate({ title: e.data('n'), titleClass: titleClass }),
            // FIXME: format duration
            content: contentTemplate({ duration: e.data('d') + 'ms' }),
            html: true
          });

          e.popover('show');
        }
      });
    };
  }])

  .controller('ReportHealthCtrl', ['ApiService', '$sce', '$scope', function($api, $sce, $scope) {

    var reportId;
    $scope.$on('report.init', init);

    function init(event, newReportId) {
      delete $scope.healthHtml;
      reportId = newReportId;
      fetchHealth().then(showHealth);
    }

    function fetchHealth() {
      return $api.http({
        method: 'GET',
        url: '/api/reports/' + reportId + '/health'
      });
    }

    function showHealth(response) {
      $scope.healthHtml = $sce.trustAsHtml(response.data.html);
    }
  }])

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

    $stateService.onState({ name: [ 'org.reports', 'org.reports.details' ] }, $scope, function(state, params) {
      if (state && state.name == 'org.reports.details') {
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
    $stateService.onState({ name: 'org.reports.details' }, $scope, function(state, params) {
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
      $scope.report = response.data;
    }
  }])

  .controller('LatestReportsCtrl', ['ApiService', 'ReportService', '$scope', '$stateParams', 'StateService', '$timeout', function($api, $reportService, $scope, $stateParams, $stateService, $timeout) {

    var hideNoNewReportsPromise;
    $scope.fetchingReports = false;

    $stateService.onState({ name: 'org.reports' }, $scope, function() {
      if ($scope.reports === undefined) {
        $scope.fetchLatestReports();
      }
    });

    $scope.fetchLatestReports = function() {

      var params = {
        organizationName: $stateParams.orgName,
        pageSize: 15
      };

      if ($scope.reports === undefined) {
        $scope.reports = false;
      } else if ($scope.reports && $scope.reports.length) {
        params.after = $scope.reports[0].id;
      }

      $scope.fetchingReports = true;

      $scope.noNewReports = false;
      if (hideNoNewReportsPromise) {
        $timeout.cancel(hideNoNewReportsPromise);
      }

      $api.http({
        method: 'GET',
        url: '/api/reports',
        params: params
      }).then(showReports);
    };

    function showReports(response) {

      $scope.fetchingReports = false;

      if (response.data.length) {
        $scope.reports = response.data.concat($scope.reports || []);
      } else if (!$scope.reports) {
        $scope.reports = [];
      } else {
        $scope.noNewReports = true;
        hideNoNewReportsPromise = $timeout(function() {
          $scope.noNewReports = false;
        }, 5000);
      }
    }
  }])

  .factory('ReportService', [function() {
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
  }])

;

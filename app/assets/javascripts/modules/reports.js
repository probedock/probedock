angular.module('probe-dock.reports', [ 'ngSanitize', 'probe-dock.api', 'probe-dock.state', 'probe-dock.tables' ])

  .factory('reports', function() {
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
  })

  .directive('reportHealthBar', function() {

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
      controller: function($attrs, reports, $scope) {
        $scope.percentages = reports.percentages($scope.report);
        $scope.tooltipText = tooltipText($scope.report, $attrs.clickForDetails !== undefined);
      },
      templateUrl: '/templates/report-health-bar.html'
    };
  })

  .directive('healthTooltips', function($compile) {
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
  })

  .controller('ReportHealthCtrl', function(api, $sce, $scope) {

    var reportId;
    $scope.$on('report.init', init);

    function init(event, newReportId) {
      delete $scope.healthHtml;
      reportId = newReportId;
      fetchHealth().then(showHealth);
    }

    function fetchHealth() {
      return api({
        url: '/reports/' + reportId + '/health'
      });
    }

    function showHealth(response) {
      $scope.healthHtml = $sce.trustAsHtml(response.data.html);
    }
  })

  .controller('ReportResultsCtrl', function(api, $scope) {

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

      return api({
        url: '/reports/' + reportId + '/results',
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
  })

  .controller('ReportsCtrl', function($scope, stateService) {

    $scope.activeTabs = {
      latest: true,
      details: false
    };
    $scope.detailsTabReportId = null;

    stateService.onState({ name: [ 'org.reports', 'org.reports.details' ] }, $scope, function(state, params) {
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
  })

  .controller('ReportDetailsCtrl', function(api, $scope, stateService) {

    var reportId;
    stateService.onState({ name: 'org.reports.details' }, $scope, function(state, params) {
      if (params.reportId != reportId) {

        delete $scope.report;
        reportId = params.reportId;
        $scope.$broadcast('report.init', reportId);

        fetchReport();
      }
    });

    function fetchReport() {
      api({
        url: '/reports/' + reportId
      }).then(showReport);
    }

    function showReport(response) {

      var report = $scope.report = response.data;

      var numberPassed = report.passedResultsCount - report.inactivePassedResultsCount,
          numberInactive = report.inactiveResultsCount,
          numberFailed = report.resultsCount - numberPassed - numberInactive;

      $scope.healthChart = {
        labels: [ 'passed', 'failed', 'inactive' ],
        data: [ numberPassed, numberFailed, numberInactive ],
        colors: [ '#62c462', '#ee5f5b', '#fbb450' ]
      };
    }
  })

  .controller('LatestReportsCtrl', function(api, reports, $scope, $stateParams, stateService, tables, $timeout) {

    tables.create($scope, 'reportsList', {
      url: '/reports',
      pageSize: 15,
      params: {
        organizationName: $stateParams.orgName
      }
    });

    var hideNoNewReportsPromise,
        latestReport;

    $scope.$on('reportsList.refresh', function() {
      $scope.noNewReports = false;
      if (hideNoNewReportsPromise) {
        $timeout.cancel(hideNoNewReportsPromise);
      }
    });

    $scope.$on('reportsList.refreshed', function(event, list, table) {

      var records = list.records,
          initialized = list.initialized;

      if ((initialized && !records.length) || (latestReport && records.length && records[0].id == latestReport.id)) {
        $scope.noNewReports = true;
        hideNoNewReportsPromise = $timeout(function() {
          $scope.noNewReports = false;
        }, 5000);
      } else if (table.pagination.start === 0) {
        latestReport = _.first(records);
      }
    });
  })

;

angular.module('probedock.reports', [ 'ngSanitize', 'probedock.api', 'probedock.orgs', 'probedock.state', 'probedock.tables' ])

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

  .controller('ReportHealthCtrl', function(api, $sce, $scope, $stateParams) {

    fetchHealth().then(showHealth);

    function fetchHealth() {
      return api({
        url: '/reports/' + $stateParams.id + '/health'
      });
    }

    function showHealth(response) {
      $scope.healthHtml = $sce.trustAsHtml(response.data.html);
    }
  })

  .controller('ReportResultsCtrl', function(api, $scope, $stateParams) {

    var page = 1,
        pageSize = 30;

    $scope.showingAllResults = false;
    $scope.fetchingMoreResults = false;
    $scope.noMoreResults = false;

    fetchResults().then(addResults);

    $scope.showAllResults = function() {
      $scope.showingAllResults = true;
    };

    $scope.showMoreResults = function() {
      page++;
      fetchResults().then(addResults);
    };

    function fetchResults() {

      $scope.fetchingMoreResults = true;

      return api({
        url: '/reports/' + $stateParams.id + '/results',
        params: {
          page: page,
          pageSize: 30
        }
      });
    }

    function addResults(response) {

      $scope.fetchingMoreResults = false;
      $scope.total = response.pagination().total;

      if (!$scope.results) {
        $scope.results = response.data;
      } else {
        $scope.results = $scope.results.concat(response.data);
      }

      $scope.noMoreResults = $scope.results.length >= $scope.total || !response.data.length;
    }
  })

  .controller('ReportsCtrl', function(api, orgs, $scope, states) {

    orgs.forwardData($scope);

    $scope.reportTabs = [];
    $scope.activeTabs = {};

    states.onState($scope, [ 'org.reports', 'org.reports.show' ], function(state, params) {
      if (state && state.name == 'org.reports.show') {
        openReportTab(params.id);
      } else {
        selectTab('latest');
      }
    });

    function openReportTab(reportId) {

      var tab = _.findWhere($scope.reportTabs, { id: reportId });
      if (!tab) {
        tab = { id: reportId, loading: true };
        $scope.reportTabs.push(tab);
      }

      selectTab(reportId);
    }

    function selectTab(id) {

      _.each($scope.activeTabs, function(value, key) {
        $scope.activeTabs[key] = false;
      });

      $scope.activeTabs[id] = true;
    }
  })

  .directive('reportDetails', function() {
    return {
      restrict: 'E',
      controller: 'ReportDetailsCtrl',
      templateUrl: '/templates/report-details.html',
      scope: {
        report: '='
      }
    };
  })

  .controller('ReportTabCtrl', function(api, $scope) {

    api({
      url: '/reports/' + $scope.reportTab.id
    }).then(function(res) {
      $scope.report = res.data;
      $scope.reportTab.loading = false;
    });

    $scope.reportTime = function() {
      if (!$scope.report) {
        return 'Loading...';
      }

      var reportTime = moment($scope.report.startedAt);

      if (reportTime.isAfter(moment().startOf('day'))) {
        reportTime = reportTime.format('HH:mm');
      } else if (reportTime.isAfter(moment().startOf('year'))) {
        reportTime = reportTime.format('MMM D HH:mm');
      } else {
        reportTime = reportTime.format('MMM D YYYY HH:mm');
      }

      var runners = _.first(_.pluck($scope.report.runners, 'name'), 3);
      return reportTime + ' by ' + runners.join(', ');
    };
  })

  .controller('ReportDetailsCtrl', function(api, $scope) {

    $scope.$watch('report', function(report) {
      if (report) {
        showReport(report);
      }
    });

    $scope.testAnchor = function(result) {
      if (result.key) {
        return 'test-k-' + result.key;
      } else {
        return 'test-n-' + result.name.replace(/\s+/g, '').replace(/[^A-Za-z0-9\_\-]/g, '');
      }
    };

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
  })

  .controller('LatestReportsCtrl', function(api, reports, $scope, $stateParams, tables, $timeout) {

    tables.create($scope, 'reportsList', {
      url: '/reports',
      pageSize: 15,
      params: {
        organizationName: $stateParams.orgName,
        withRunners: 1,
        withProjects: 1,
        withProjectVersions: 1,
        withCategories: 1
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

  .directive('healthTooltips', function($compile, $document) {
    return function(scope, element, attrs) {

      var titleTemplate = _.template('<strong class="<%= titleClass %>"><%- title %></strong>'),
          contentTemplate = _.template('<ul class="list-unstyled"><li><strong>Duration:</strong> <%- duration %></li></ul>');

      element.on('click', 'a', function() {

        var e = $(this);

        var testElement;
        if (e.data('k')) {
          testElement = $('#test-k-' + e.data('k'));
        } else if (e.data('n')) {
          testElement = $('#test-n-' + e.data('n').replace(/\s+/g, '').replace(/[^A-Za-z0-9\_\-]/g, ''));
        }

        if (testElement.length) {
          $document.duScrollTo(testElement, 50, 1000);
        }
      });

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

;

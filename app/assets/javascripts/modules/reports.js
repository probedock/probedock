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
        tab = { id: reportId };
        $scope.reportTabs.push(tab);
      }

      selectTab(reportId);

      if (!tab.report) {
        if (tab.loading) {
          return;
        }

        tab.loading = true;

        getTabReport(reportId).then(function(report) {
          tab.loading = false;
          tab.report = report;
        });
      }
    }

    function getTabReport(id) {
      return api({
        url: '/reports/' + id
      });
    }

    function selectTab(id) {

      _.each($scope.activeTabs, function(value, key) {
        $scope.activeTabs[key] = false;
      });

      $scope.activeTabs[id] = true;
    }
  })

  .controller('ReportDetailsCtrl', function(api, $scope, $stateParams) {

    api({
      url: '/reports/' + $stateParams.id
    }).then(showReport);

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

  .controller('LatestReportsCtrl', function(api, reports, $scope, $stateParams, tables, $timeout) {

    tables.create($scope, 'reportsList', {
      url: '/reports',
      pageSize: 15,
      params: {
        organizationName: $stateParams.orgName,
        withProjects: 1,
        withProjectVersions: 1,
        withRunners: 1
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

;

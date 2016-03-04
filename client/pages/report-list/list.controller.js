angular.module('probedock.reportListPage').controller('ReportListPageCtrl', function(api, orgs, $scope, $stateParams, states, tables, $timeout) {
  orgs.forwardData($scope);

  var hideNoNewReportsPromise,
      latestReport;

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

  $scope.filtersClass = 'hidden-xs';

  $scope.toggleFilters = function() {
    $scope.filtersClass = $scope.filtersClass == 'hidden-xs' ? '' : 'hidden-xs';
  };

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
});

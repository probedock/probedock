angular.module('probedock.reportListPage').controller('ReportListPageCtrl', function(api, orgs, routeOrgName, $scope, states, tables, $timeout) {
  orgs.forwardData($scope);

  var filterStateLoaded,
      latestReport,
      hideNoNewReportsPromise;

  tables.create($scope, 'reportsList', {
    url: '/reports',
    pageSize: 15,
    params: {
      organizationName: routeOrgName,
      withRunners: 1,
      withProjects: 1,
      withProjectVersions: 1,
      withCategories: 1
    }
  });

  $scope.$watch('reportsList.params', function() {
    filterStateLoaded = false;
  }, true);

  $scope.$on('reportsList.refresh', function() {
    $scope.noNewReports = false;
    if (hideNoNewReportsPromise) {
      $timeout.cancel(hideNoNewReportsPromise);
    }
  });

  $scope.$on('reportsList.refreshed', function(event, list, table) {

    var records = list.records;

    /**
     * This code handles the display of the "no new reports" message.
     * The message is supposed to be shown if the user presses the refresh
     * button and no new reports are available.
     *
     * The `filterStateLoaded` variable indicates whether we have already
     * retrieved reports for the current filters. It is cleared every time
     * the filters change, so that we never display "no new reports" when the
     * user changes the filters.
     *
     * We display the message in two cases:
     *
     * 1) If reports were already loaded for the current filters, and the
     *    response is empty. (It means that there were no reports before and
     *    there are still none available.)
     *
     * 2) If reports were already loaded for the current filters, and the
     *    first report in the response is the same as the first report that
     *    was previously loaded. (No new reports are available.)
     */
    if ((filterStateLoaded && !records.length) || (filterStateLoaded && latestReport && records.length && records[0].id == latestReport.id)) {
      $scope.noNewReports = true;
      hideNoNewReportsPromise = $timeout(function() {
        $scope.noNewReports = false;
      }, 5000);
    } else if (table.pagination.start === 0) {
      // Keep track of the latest report.
      latestReport = _.first(records);
    }

    filterStateLoaded = true;
  });

  $scope.filtersClass = 'hidden-xs';

  $scope.toggleFilters = function() {
    $scope.filtersClass = $scope.filtersClass == 'hidden-xs' ? '' : 'hidden-xs';
  };

  $scope.statuses = [{
    name: 'of any',
    status: 'any'
  }, {
    name: 'failing',
    status: 'failed'
  }, {
    name: 'inactive',
    status: 'inactive'
  }, {
    name: 'passing',
    status: 'passed'
  }];

  $scope.newTests = [{
    name: 'of any',
    new: null
  }, {
    name: 'new',
    new: true
  }, {
    name: 'recurring',
    new: false
  }];

  $scope.selectParams = {
    status: 'any',
    new: null
  };

  $scope.$watch('selectParams', function(newValue) {
    if (newValue.status == 'any') {
      delete $scope.reportsList.params.status;
    } else {
      $scope.reportsList.params.status = [ newValue.status ];
    }

    if (_.isNull(newValue.new)) {
      delete $scope.reportsList.params.newTests;
    } else {
      $scope.reportsList.params.newTests = newValue.new;
    }
  }, true);

  $scope.reportTabs = [];
  $scope.tabset = {
    active: 0
  };

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

    $timeout(function() {
      selectTab($scope.reportTabs.indexOf(tab) + 1);
    });
  }

  function selectTab(index) {
    $scope.tabset.active = index == 'latest' ? 0 : index;
  }
});

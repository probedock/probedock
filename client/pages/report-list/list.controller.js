angular.module('probedock.reportListPage').controller('ReportListPageCtrl', function(api, orgs, $scope, $stateParams, states, tables, $timeout) {
  orgs.forwardData($scope);

  var filterStateLoaded,
      latestReport,
      hideNoNewReportsPromise;

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

  $scope.$watch('reportsList.params', function() {
    filterStateLoaded = false;
  }, true);

  /**
   * Manage the filter based on toggle buttons (like: status or kind of tests)
   *
   * @param toggleName The name of the scope model
   * @param paramName The name of query parameter
   */
  function manageToggleParams(toggleName, paramName) {
    // Build the array of toggles
    var params = _.reduce($scope[toggleName], function(memo, value, name) {
      if (value) {
        memo.push(name);
      }
      return memo;
    }, []);

    // Check if not all the toggles are active or if there is at least one toggle
    if (params.length != _.keys($scope[toggleName]).length && params.length > 0) {
      $scope.reportsList.params[paramName] = params;
    } else if ($scope.reportsList.params[paramName]) { // Check if it is necessary to remove the params for the request
      delete $scope.reportsList.params[paramName];
    }
  }

  $scope.$watch('statuses', function() {
    manageToggleParams('statuses', 'status');
  }, true);

  $scope.$watch('kinds', function() {
    manageToggleParams('kinds', 'kind');
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

  $scope.kinds = [{
    name: 'of any',
    kind: 'any'
  }, {
    name: 'new',
    kind: 'new'
  }, {
    name: 'recurring',
    kind: 'existing'
  }];

  $scope.selectParams = {
    status: 'any',
    kind: 'any'
  };

  $scope.$watch('selectParams', function(newValue) {
    if (newValue.status == 'any') {
      delete $scope.reportsList.params.status;
    } else {
      $scope.reportsList.params.status = [ newValue.status ];
    }

    if (newValue.kind == 'any') {
      delete $scope.reportsList.params.kind;
    } else {
      $scope.reportsList.params.kind = [ newValue.kind ];
    }
  }, true);

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

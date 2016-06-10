angular.module('probedock.reportListPage').controller('ReportListPageCtrl', function(api, orgs, routeOrgName, $scope, states, tables, $timeout, $location, $stateParams) {
  orgs.forwardData($scope);

  var filterStateLoaded,
      latestReport,
      hideNoNewReportsPromise;

  var params = {
    organizationName: routeOrgName,
    withRunners: 1,
    withProjects: 1,
    withProjectVersions: 1,
    withCategories: 1
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

  /**
   * Define the array parameters. All of them will
   * be managed in the same way.
   */
  var arrayParamDefs = [{
    privateName: 'runnerIds',
    publicName: 'runners'
  }, {
    privateName: 'projectIds',
    publicName: 'projects'
  }, {
    privateName: 'projectVersionNames',
    publicName: 'versions'
  }, {
    privateName: 'categoryNames',
    publicName: 'categories'
  }];

  manageLocationParams($stateParams, params);

  tables.create($scope, 'reportsList', {
    url: '/reports',
    pageSize: 15,
    params: params
  });

  $scope.$watch('reportsList.params', function() {
    filterStateLoaded = false;
  }, true);

  /**
   * Setup the watchers to reflect the filters in the URL when configured from the fields
   */
  _.each(arrayParamDefs, function(paramDef) {
    $scope.$watch('reportsList.params.' + paramDef.privateName, function(newValue, oldValue) {
      if (newValue != null && newValue != undefined) {
        $location.search(paramDef.publicName, newValue);
      }
    });
  });

  // Listener to detect the location changes and reflect them to the filters
  $scope.$on('$locationChangeSuccess', function() {
    manageLocationParams($location.search());
  });

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

  $scope.$watch('selectParams', function(newValue) {
    if (newValue.status == 'any') {
      $location.search('status', null);
      delete $scope.reportsList.params.status;
    } else {
      $location.search('status', _.findWhere($scope.statuses, { status: newValue.status }).name);
      $scope.reportsList.params.status = [ newValue.status ];
    }

    if (_.isNull(newValue.new)) {
      $location.search('tests', null);
      delete $scope.reportsList.params.newTests;
    } else {
      $location.search('tests', _.findWhere($scope.newTests, { new: newValue.new }).name);
      $scope.reportsList.params.newTests = newValue.new;
    }
  }, true);

  $scope.reportTabs = [];
  $scope.lastReportTabIndex = 1;
  $scope.tabset = {
    active: 0
  };

  states.onStateChangeSuccess($scope, [ 'org.reports', 'org.reports.show' ], function(state, params) {
    if (state && state.name == 'org.reports.show') {
      openReportTab(params.id);
    } else {
      selectTab('latest');
    }
  });

  $scope.reportTime = function(report) {
    if (!report) {
      return 'Loading...';
    }

    var reportTime = moment(report.startedAt);

    if (reportTime.isAfter(moment().startOf('day'))) {
      reportTime = reportTime.format('HH:mm');
    } else if (reportTime.isAfter(moment().startOf('year'))) {
      reportTime = reportTime.format('MMM D HH:mm');
    } else {
      reportTime = reportTime.format('MMM D YYYY HH:mm');
    }

    var runners = _.first(_.pluck(report.runners, 'name'), 3);
    return reportTime + ' by ' + runners.join(', ');
  };

  function openReportTab(reportId) {

    var tab = _.findWhere($scope.reportTabs, { id: reportId });
    if (!tab) {
      tab = {
        id: reportId,
        index: $scope.lastReportTabIndex++
      };

      $scope.reportTabs.push(tab);
    }

    $timeout(function() {
      selectTab(tab.index);
    });

    if (!tab.report) {
      if (tab.loading) {
        return;
      }

      tab.loading = true;

      fetchReport(reportId).then(function(report) {
        tab.loading = false;
        tab.report = report;
      });
    }
  }

  function selectTab(index) {
    $scope.tabset.active = index == 'latest' ? 0 : index;
  }

  function fetchReport(id) {
    return api({
      url: '/reports/' + id
    }).then(function(res) {
      return res.data;
    });
  }

  /**
   * Manage the location parameters to update the filters
   *
   * @param paramsProvider The parameters provider
   * @param parameters Optional map of parameters to update. Useful for initial creation of params
   */
  function manageLocationParams(paramsProvider, parameters) {
    var params = parameters ? parameters : $scope.reportsList.params;

    /**
     * When the controller is initialized, we retrieve the array parameters from the
     * $stateParams object and we set the filters to the query params values.
     */
    _.each(arrayParamDefs, function(arrayParamDef) {
      // Parameters set in the URL
      if (!_.isUndefined(paramsProvider[arrayParamDef.publicName])) {
        // Parameters must be converted to an array
        if (!_.isArray(paramsProvider[arrayParamDef.publicName])) {
          params[arrayParamDef.privateName] = [ paramsProvider[arrayParamDef.publicName] ];
        } else {
          params[arrayParamDef.privateName] = paramsProvider[arrayParamDef.publicName];
        }
      } else {
        delete params[arrayParamDef.privateName];
      }
    });

    /**
     * Same for the test types param
     */
    if (!_.isUndefined(paramsProvider.tests)) {
      // If the query parameters is an array, we get the last tests of the array
      var testsValue = _.isArray(paramsProvider.tests) ? paramsProvider.tests[paramsProvider.tests.length - 1] : paramsProvider.tests;

      var testsObject = _.findWhere($scope.newTests, { name: testsValue });

      if (!_.isUndefined(testsObject)) {
        // params.newTests = testsObject.new;
        $scope.selectParams.new = testsObject.new;
      }
    } else {
      $scope.selectParams.new = null;
    }

    /**
     * And also for the status
     */
    if (!_.isUndefined(paramsProvider.status)) {
      // If the query parameters is an array, we get the last status of the array
      var statusValue = _.isArray(paramsProvider.status) ? paramsProvider.status[paramsProvider.status.length - 1] : paramsProvider.status;

      var statusObject = _.findWhere($scope.statuses, { name: statusValue });

      if (!_.isUndefined(statusObject)) {
        // params.status = [ statusObject.status ];
        $scope.selectParams.status = statusObject.status;
      }
    } else {
      $scope.selectParams.status = 'any';
    }
  }
});

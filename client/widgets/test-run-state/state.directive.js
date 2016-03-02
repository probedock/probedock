angular.module('probedock.testRunStateWidget').directive('testRunStateWidget', function() {
  return {
    restrict: 'E',
    controller: 'TestRunStateWidgetCtrl',
    templateUrl: '/templates/widgets/test-run-state/state.template.html',
    scope: {
      organization: '=',
      project: '=',
      filtersDisabled: '=?',
      useLatestVersion: '=?',
      chartHeight: '@',
      linkToVersion: '=?'
    }
  };
}).controller('TestRunStateWidgetCtrl', function(api, $scope) {
  // Set default configuration for the directive
  _.defaults($scope, {
    filtersDisabled: false,
    useLatestVersion: false,
    linkToVersion: true,
    chartHeight: 200,
    params: {
      projectVersionId: null,
      runnerId: null
    }
  });

  var avoidFetchByParams = true;
  var paramsManuallyUpdated = false;

  if ($scope.useLatestVersion) {
    fetchLatestVersion();
  } else if ($scope.project) {
    fetchReportByTechnicalUser();
  }

  $scope.$watch('params', function (newParams, oldParams) {
    // Make sure to fetch report when params have been updated
    if (!avoidFetchByParams && !paramsManuallyUpdated) {
      fetchReport();
    } else if (paramsManuallyUpdated) { // Reset the manual flag
      paramsManuallyUpdated = false;
    }
  }, true);

  /**
   * Retrieve the latest version of a project. If not found,
   * fallback to a standard lookup for a report.
   * @returns {*} A promise
   */
  function fetchLatestVersion() {
    $scope.loading = true;

    return api({
      url: '/projectVersions',
      params: {
        projectId: $scope.project.id,
        sort: 'createdAt',
        pageSize: 1,
        page: 1
      }
    }).then(function(res) {
      if (res.data.length == 1) {
        // Manually update the project version to make sure the UI shows the correct filters
        paramsManuallyUpdated = true;
        $scope.params.projectVersionId = res.data[0].id;
        return fetchReportByTechnicalUser();
      } else {
        return fetchReport();
      }
    });
  }

  /**
   * Retrieve the latest report done by a technical user for the $scope.params. If not
   * found, fallback to a standard lookup for a report
   * @returns {*} A promise
   */
  function fetchReportByTechnicalUser() {
    $scope.loading = true;

    // Do a call to the reports API to get the most recent report for a any technical user
    return api({
      url: '/reports',
      params: buildReportsParams({ technical: true })
    }).then(function(res) {
      if (res.data.length == 1) {
        // Retrieve the first technical runner
        var technicalRunner = _.find(res.data[0].runners, function(runner) { return runner.technical; });

        // Manually update the params to make sure the UI show the correct filter
        paramsManuallyUpdated = true;
        $scope.params.runnerId = technicalRunner.id;

        return processData(res.data[0]);
      } else {
        return fetchReport();
      }
    });
  }

  /**
   * Fetch a report by $scope.params and if there is no params, then it will
   * try to retrieve the latest report of the project through project.lastReportId
   * @returns {*} A promise
   */
  function fetchReport() {
    $scope.loading = true;

    // Use the reports API if there is any criteria
    var url, params;
    if ($scope.params.projectVersionId || $scope.params.runnerId) {
      url = '/reports';
      params = buildReportsParams();
    } else if ($scope.project.lastReportId) { // Lookup by lastReportId
      url = '/reports/' + $scope.project.lastReportId;
      params = {
        withProjectCountsFor: $scope.project.id
      };
    } else { // No data can be retrieved
      return processData(null);
    }

    return api({
      url: url,
      params: params
    }).then(function(res) {
      if (res.data.length == 0 && $scope.params.runnerId) {
        $scope.params.runnerId = null;
      } else {
        return processData(_.isArray(res.data) ? res.data[0] : res.data);
      }
    });
  }

  /**
   * Process the data to make them available to the UI. In addition,
   * it will also restore few flag variables.
   * @param report The report data
   */
  function processData(report) {
    $scope.report = report;

    if ($scope.report) {
      // Update the runner if the filters are enabled
      if (!$scope.filtersDisabled && !$scope.params.runnerId) {
        paramsManuallyUpdated = true;
        $scope.params.runnerId = $scope.report.runners[0].id;
      }

      // Calculate the metrics
      var numberPassed = report.projectCounts.passedResultsCount - report.projectCounts.inactivePassedResultsCount,
        numberInactive = report.projectCounts.inactiveResultsCount,
        numberFailed = report.projectCounts.resultsCount - numberPassed - numberInactive;

      // Prepare the chart data series
      $scope.stateChart = {
        labels: ['passed', 'failed', 'inactive'],
        data: [numberPassed, numberFailed, numberInactive],
        colors: ['#62c462', '#ee5f5b', '#fbb450']
      };
    }

    // Restore flags
    $scope.loading = false;
    avoidFetchByParams = false;
  }

  /**
   * Build the reports API parameters
   * @param baseParams The base parameters
   * @returns {*} The extended parameters
   */
  function buildReportsParams(baseParams) {
    // Common parameters to make sure only one report is retrieved with correct data
    var extendedParams = {
      withRunners: 1,
      withProjectVersions: 1,
      withProjectCountsFor: $scope.project.id,
      organizationId: $scope.organization.id,
      pageSize: 1,
      page: 1
    };

    // Filtered by project version id
    if ($scope.params.projectVersionId) {
      extendedParams.projectVersionIds = [ $scope.params.projectVersionId ];
    } else {
      extendedParams.projectIds = [ $scope.project.id ];
    }

    // Filtered by runner id
    if ($scope.params.runnerId) {
      extendedParams.runnerIds = [ $scope.params.runnerId ];
    }

    // Extend common parameters with base parameters if any
    return _.extend(extendedParams, baseParams || {});
  }
});

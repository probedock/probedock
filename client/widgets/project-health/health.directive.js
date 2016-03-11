angular.module('probedock.projectHealthWidget').directive('projectHealthWidget', function() {
  return {
    restrict: 'E',
    templateUrl: '/templates/widgets/project-health/health.template.html',
    controller: 'ProjectHealthWidgetCtrl',
    scope: {
      organization: '=',
      project: '=',
      linkable: '=?',
      compact: '=?',
      filtersDisabled: '=?',
      chartHeight: '@'
    }
  };
}).directive('projectHealthContent', function() {
  return {
    restrict: 'E',
    templateUrl: '/templates/widgets/project-health/health.content.template.html',
    controller: 'ProjectHealthContentCtrl',
    scope: {
      organization: '=',
      project: '=',
      linkable: '=?',
      filtersDisabled: '=?',
      chartHeight: '@'
    }
  };
}).controller('ProjectHealthWidgetCtrl', function($scope, api) {
  // Set default configuration for the directive
  _.defaults($scope, {
    compact: false,
    linkable: true,
    filtersDisabled: false,
    chartHeight: 200
  });
}).controller('ProjectHealthContentCtrl', function($scope, api) {
  var avoidFetchByParams = true;
  var paramsProgrammaticallyUpdated = false;

  // Empty state chart to show when there is no data
  var emptyStateChart = {
    labels: [ '' ],
    data: [ 1 ],
    colors: [ '#7a7a7a' ]
  };

  // Set default configuration for the directive
  _.defaults($scope, {
    linkable: true,
    filtersDisabled: false,
    chartHeight: 200,
    params: {
      projectVersionId: null,
      runnerId: null
    },
    stateChart: emptyStateChart,
    showChart: false
  });

  if ($scope.project) {
    fetchReportByTechnicalUser();
  }

  $scope.$watch('params', function () {
    // Make sure to fetch report when params have been updated
    if (!avoidFetchByParams && !paramsProgrammaticallyUpdated) {
      fetchReport();
    } else if (paramsProgrammaticallyUpdated) { // Reset the manual flag
      paramsProgrammaticallyUpdated = false;
    }
  }, true);

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
        paramsProgrammaticallyUpdated = true;
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

    return api({
      url: '/reports',
      params: buildReportsParams()
    }).then(function(res) {
      return processData(res.data[0]);
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
      if (!$scope.filtersDisabled) {
        // Update the project version id if the filters are enabled
        if (!$scope.params.projectVersionId) {
          paramsProgrammaticallyUpdated = true;
          $scope.params.projectVersionId = _.findWhere($scope.report.projectVersions, { projectId: $scope.project.id }).id;
        }

        // Update the runner if the filters are enabled
        if (!$scope.params.runnerId) {
          paramsProgrammaticallyUpdated = true;
          $scope.params.runnerId = $scope.report.runners[0].id;
        }
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
    } else { // Empty chart
      $scope.stateChart = emptyStateChart;
    }

    // Restore flags
    $scope.loading = false;
    avoidFetchByParams = false;
    $scope.showChart = true;
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
      projectId: $scope.project.id,
      pageSize: 1,
      page: 1
    };

    // Filtered by project version id
    if ($scope.params.projectVersionId) {
      extendedParams.projectVersionIds = [ $scope.params.projectVersionId ];
    }

    // Filtered by runner id
    if ($scope.params.runnerId) {
      extendedParams.runnerIds = [ $scope.params.runnerId ];
    }

    // Extend common parameters with base parameters if any
    return _.extend(extendedParams, baseParams || {});
  }
});;

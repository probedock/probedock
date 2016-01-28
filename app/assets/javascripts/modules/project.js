angular.module('probedock.project', [ 'probedock.api', 'probedock.forms', 'probedock.utils' ])

  .controller('ProjectCtrl', function (api, forms, orgs, projects, $scope, $state, $stateParams) {
    orgs.forwardData($scope);

    api({
      url: '/projects',
      params: {
        organizationName: $stateParams.orgName,
        name: $stateParams.projectName
      }
    })
    .then(function (response) {
      if (response.data[0]) {
        project = response.data[0];

        return api({
          url: '/reports',
          params: {
            projectId: project.id
          }
        })
        .then(function (response) {
          $scope.project = _.extend(project, {
            reportsCount: response.pagination().filteredTotal
          });
        });
      }
    });
  })

  .directive('projectRecentActivity', function() {
    return {
      restrict: 'E',
      controller: 'ProjectRecentActivityCtrl',
      controllerAs: 'ctrl',
      templateUrl: '/templates/project-recent-activity.html',
      scope: {
        organization: '=',
        project: '='
      }
    };
  })

  .controller('ProjectRecentActivityCtrl', function(api, $scope) {

    $scope.$watch('project', function(value) {
      if (value) {
        fetchReports();
      }
    });

    function fetchReports() {
      return api({
        url: '/reports',
        params: {
          pageSize: 5,
          projectId: $scope.project.id,
          withRunners: 1,
          withProjects: 1,
          withProjectVersions: 1,
          withCategories: 1,
          withProjectCountsFor: $scope.project.id
        }
      }).then(showReports);
    }

    function showReports(response) {
      $scope.reports = response.data;
    }
  })

.directive('projectHealthChart', function() {
  return {
    restrict: 'E',
    controller: 'ProjectHealthChartCtrl',
    templateUrl: '/templates/project-health.html',
    scope: {
      project: '='
    }
  };
})

.controller('ProjectHealthChartCtrl', function(api, $scope) {
  $scope.chart = {
    data: [],
    labels: ['passed', 'failed', 'inactive'],
    colors: ['#62c462', '#ee5f5b', '#fbb450'],
    params: {}

  };

  $scope.projectVersionChoices = [];

  $scope.$watch('project', function(value) {
    if (value) {
      fetchMetrics();
    }
  });

  var ignoreChartParams = true;
  $scope.$watch('chart.params', function(value) {
    if (value && !ignoreChartParams) {
      fetchMetrics();
    }

    ignoreChartParams = false;
  }, true);

  function fetchMetrics() {
    var params = {};

    if ($scope.chart.params.projectVersion) {
      params.projectVersionId = $scope.chart.params.projectVersion.id;
    } else {
      params.projectId = $scope.project.id;
    }

    return api({
      url: '/metrics/projectHealth',
      params: params
    }).then(showMetrics);
  }

  function showMetrics(response) {
    if (!response.data) {
      return;
    }

    if (!$scope.projectHealth) {
      $scope.latestVersion = response.data.projectVersion;
    }

    var data = $scope.projectHealth = response.data;

    var numberPassed = data.passedTestsCount - data.inactivePassedTestsCount,
        numberInactive = data.inactiveTestsCount,
        numberFailed = data.runTestsCount - numberPassed - numberInactive;

    $scope.chart.data = [ numberPassed, numberFailed, numberInactive ];
  }
})
;
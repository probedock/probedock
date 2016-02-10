angular.module('probedock.projectHealthWidget').directive('projectHealthWidget', function() {
  return {
    restrict: 'E',
    controller: 'ProjectHealthWidgetCtrl',
    templateUrl: '/templates/widgets/project-health/health.template.html',
    scope: {
      project: '='
    }
  };
}).controller('ProjectHealthWidgetCtrl', function(api, $scope) {
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
});

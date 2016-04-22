angular.module('probedock.testingActivityWidget').directive('testingActivityWidget', function() {
  return {
    restrict: 'E',
    controller: 'TestingActivityWidgetCtrl',
    templateUrl: function(element, attr) {
      if (attr.type == 'projects') {
        return '/templates/widgets/testing-activity/activity.project.template.html';
      } else {
        return '/templates/widgets/testing-activity/activity.template.html';
      }
    },
    scope: {
      organization: '=',
      project: '=',
      nbDays: '=?'
    }
  };
}).controller('TestingActivityWidgetCtrl', function(api, $scope) {

  var chartConfig = {
    written: {
      url: '/metrics/newTestsByDay',
      valueFieldName: 'testsCount'
    },
    run: {
      url: '/metrics/reportsByDay',
      valueFieldName: 'runsCount'
    }
  };

  $scope.nbDays = $scope.nbDays || 30;

  $scope.chart = {
    data: [],
    labels: [],
    type: 'written',
    params: {
      projectIds: [],
      userIds: [],
      nbDays: $scope.nbDays
    },
    options: {
      tooltips: {
        callbacks: {
          title: function() { return ''; },
          label: function(tooltipItems, data) {
            if ($scope.chart.type == 'written') {
              return tooltipItems.yLabel + ' new test' + (tooltipItems.yLabel > 1 ? 's' : '') + ' on ' + tooltipItems.xLabel;
            } else {
              return tooltipItems.yLabel + ' run' + (tooltipItems.yLabel > 1 ? 's' : '') + ' on ' + tooltipItems.xLabel;
            }
          }
        }
      }
    }
  };

  $scope.$watch('organization', function(value) {
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

  $scope.$watch('chart.type', function(value) {
    fetchMetrics();
  }, true);

  function fetchMetrics() {
    if ($scope.project) {
      $scope.chart.params.projectIds = [$scope.project.id];
    }

    return api({
      url: chartConfig[$scope.chart.type].url,
      params: _.extend({}, $scope.chart.params, {
        organizationId: $scope.organization.id
      })
    }).then(showMetrics);
  }

  function showMetrics(response) {
    if (!response.data.length) {
      return;
    }

    var series = [];
    $scope.chart.data = [ series ];
    $scope.chart.labels.length = 0;
    $scope.totalCount = 0;

    var fieldName = chartConfig[$scope.chart.type].valueFieldName;

    _.each(response.data, function(data) {
      $scope.chart.labels.push(moment(data.date).format('DD.MM'));
      series.push(data[fieldName]);
      $scope.totalCount += data[fieldName];
    });
  }
});

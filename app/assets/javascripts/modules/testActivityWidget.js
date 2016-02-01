angular.module('probedock.testActivityWidget', [ 'probedock.api' ])
  .directive('testActivityChart', function() {
    return {
      restrict: 'E',
      controller: 'TestActivityChartCtrl',
      templateUrl: function(element, attr) {
        if (attr.type == 'projects') {
          return '/templates/project-test-activity-chart.html';
        } else {
          return '/templates/test-activity-chart.html';
        }
      },
      scope: {
        organization: '=',
        project: '=',
        nbDays: '=?'
      }
    };
  })

  .controller('TestActivityChartCtrl', function(api, $scope) {

    var chartConfig = {
      written: {
        url: '/metrics/newTestsByDay',
        tooltipTemplate: '<%= value %> new tests on <%= label %>',
        valueFieldName: 'testsCount'
      },
      run: {
        url: '/metrics/reportsByDay',
        tooltipTemplate: '<%= value %> runs on <%= label %>',
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
        pointHitDetectionRadius: 5,

        // Will be set from chartConfig based on chart type
        tooltipTemplate: '',

        /*
         * Fix for space issue in the Y axis labels
         * see: https://github.com/nnnick/Chart.js/issues/729
         * see: http://stackoverflow.com/questions/26498171/how-do-i-prevent-the-scale-labels-from-being-cut-off-in-chartjs
         */
        scaleLabel: function(object) {
          return '  ' + object.value;
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

      $scope.chart.options.tooltipTemplate = chartConfig[$scope.chart.type].tooltipTemplate;

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
  })
;

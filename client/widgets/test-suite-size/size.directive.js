angular.module('probedock.testSuiteSizeWidget', [ 'probedock.api' ]).directive('testSuiteSizeWidget', function() {
    return {
      restrict: 'E',
      controller: 'TestSuiteSizeWidgetCtrl',
      templateUrl: '/templates/widgets/test-suite-size/size.template.html',
      scope: {
        organization: '=',
        project: '=',
        nbWeeks: '=?'
      }
    };
  }).controller('TestSuiteSizeWidgetCtrl', function(api, $scope) {

    $scope.nbWeeks = $scope.nbWeeks || 30;

    $scope.chart = {
      data: [],
      labels: [],
      params: {
        projectIds: [],
        userIds: [],
        nbWeeks: $scope.nbWeeks
      },
      options: {
        tooltips: {
          callbacks: {
            title: function() { return ''; },
            label: function(tooltipItems, data) {
              return tooltipItems.yLabel + ' test' + (tooltipItems.yLabel > 1 ? 's' : '') + ' on ' + tooltipItems.xLabel;
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

    function fetchMetrics() {
      if ($scope.project) {
        $scope.chart.params.projectIds = [$scope.project.id];
      }

      return api({
        url: '/metrics/testsByWeek',
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
      $scope.totalCount = _.last(response.data).testsCount;
      $scope.countDelta = _.last(response.data).testsCount - _.first(response.data).testsCount;

      _.each(response.data, function(data) {
        $scope.chart.labels.push(moment(data.date).format('DD.MM.YYYY'));
        series.push(data.testsCount);
      });
    }
  })
;

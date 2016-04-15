angular.module('probedock.sparkline').directive('sparkline', function($timeout) {
  return {
    restrict: 'E',
    controller: 'SparklineCtrl',
    templateUrl: '/templates/components/sparkline/sparkline.template.html',
    scope: {
      data: '=?',
      displayTickLine: '=?',
      displayDots: '=?'
    },
    link: function($scope, elem, attrs, ctrl) {
      // Dirty hack to make sure the trend line is resized the first
      // time it is displayed as there is no window resize event and the
      // trend line does not take 100% width every time.
      $timeout(function() {
        delete $scope.chartOptions.chart.width;
      }, 200);
    }
  };
}).controller('SparklineCtrl', function($scope, numberFilter) {
  if (_.isUndefined($scope.data)) {
    throw new Error("Data must be provided.");
  }

  _.defaults($scope, {
    displayTickLine: false,
    displayDots: false
  });

  // Transform the data to an array of object with { x: <value>, y: <value> } if necessary, otherwise use as it is
  if (_.isObject($scope.data[0]) && !_.isUndefined($scope.data[0].x) && !_.isUndefined($scope.data[0].y)) {
    $scope.chartData = $scope.data;
  } else {
    $scope.chartData = _.map($scope.data, function(item, idx) {
      return { x: idx, y: item };
    });
  }

  _.defaults($scope, {
    chartOptions: {
      chart: {
        type: 'sparklinePlus',
        height: 30,
        width: 100,
        margin: {
          top: 2,
          bottom: 2,
          left: 10,
          right: 5
        },
        xTickFormat: function() { return ''; },
        yTickFormat: function(v) { return numberFilter(v); },
        showLastValue: false,
        sparkline: {
          color: function() { return '#395c82'; }
        }
      }
    }
  });
});

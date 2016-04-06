angular.module('probedock.sparkline').directive('sparkline', function() {
  return {
    restrict: 'E',
    controller: 'SparklineCtrl',
    templateUrl: '/templates/components/sparkline/sparkline.template.html',
    scope: {
      data: '=?',
      displayTickLine: '=?',
      displayDots: '=?'
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
  if (_.isObject($scope.data[0]) && !_.isUndefined($scope.data[0].x) && _.isUndefined($scope.data[0].y)) {
    $scope.chartData = $scope.data;
  }
  else {
    $scope.chartData = _.map($scope.data, function(item, idx) {
      return { x: idx, y: item };
    });
  }

  _.defaults($scope, {
    options: {
      chart:{
        type: 'sparklinePlus',
        height: 30,
        width: 200,
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

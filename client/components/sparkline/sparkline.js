angular.module('probedock.sparkline').directive('sparkline', function() {
  return {
    restrict: 'E',
    controller: 'SparklineCtrl',
    templateUrl: '/templates/components/sparkline/sparkline.template.html',
    scope: {
      data: '=?'
    }
  };
}).controller('SparklineCtrl', function($scope) {
  if (_.isUndefined($scope.data)) {
    throw new Error("Data must be provided.");
  }

  _.defaults($scope, {
    datasets: [ $scope.data ],
    labels: new Array($scope.data.length),
    options: {
      animation: false,
      showTooltips: false,
      scaleLineColor : "rgba(0,0,0,0)",
      scaleShowLabels : false,
      scaleShowGridLines : false,
      pointDot : false,
      datasetFill : false,
      scaleFontSize : 0,
      scaleFontColor : "rgba(0,0,0,0)"
    }
  });
});

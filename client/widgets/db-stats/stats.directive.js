angular.module('probedock.dbStatsWidget').directive('dbStatsWidget', function() {
  return {
    restrict: 'E',
    controller: 'DbStatsWidgetCtrl',
    templateUrl: '/templates/widgets/db-stats/stats.template.html',
    scope: {
      organization: '='
    }
  };
}).controller('DbStatsWidgetCtrl', function(api, $scope) {
  _.defaults($scope, {
    loading: true
  });

  fetchStats();

  function fetchStats() {
    $scope.loading = true;

    return api({
      url: '/platformManagement/dbStats'
    }).then(function(response) {
      if (response.data) {
        var stats = response.data;

        $scope.total = {
          rowsCount: 0,
          tableSize: 0,
          indexesSize: 0,
          totalSize: 0
        };

        // Calculate the totals
        _.each(stats, function(stat) {
          $scope.total.rowsCount += stat.rowsCount;
          $scope.total.tableSize += stat.tableSize;
          $scope.total.indexesSize += stat.indexesSize;
          $scope.total.totalSize += stat.totalSize;
        });

        // Calculate the proportions
        _.each(stats, function(stat) {
          stat.rowsProportion = stat.rowsCount / $scope.total.rowsCount * 100;
          stat.totalSizeProportion = stat.totalSize / $scope.total.totalSize * 100;
        });

        // Update the view
        $scope.stats = stats;
        $scope.loading = false;
      }

      $scope.started = true;
    });
  }
});

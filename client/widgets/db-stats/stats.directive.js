angular.module('probedock.dbStatsWidget').directive('dbStatsWidget', function() {
  return {
    restrict: 'E',
    controller: 'DbStatsWidgetCtrl',
    templateUrl: '/templates/widgets/db-stats/stats.template.html',
    scope: {
      top: '=?'
    }
  };
}).controller('DbStatsWidgetCtrl', function(api, $scope, bootstrap) {
  _.defaults($scope, {
    top: 5,
    loading: true
  });

  fetchStats();

  bootstrap.forward($scope);

  $scope.hasMore = function() {
    return $scope.stats.length > $scope.currentStats.length;
  };

  $scope.more = function() {
    $scope.currentStats = $scope.stats;
  };

  $scope.less = function() {
    $scope.currentStats = $scope.stats.slice(0, $scope.top)
  };

  function fetchStats() {
    $scope.loading = true;

    return api({
      url: '/platformManagement/dbStats'
    }).then(function(response) {
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

      var totalCumulativeTrends = [];
      // Calculate the proportions and cumulative trends
      _.each(stats, function(stat) {
        stat.rowsProportion = stat.rowsCount / $scope.total.rowsCount * 100;
        stat.totalSizeProportion = stat.totalSize / $scope.total.totalSize * 100;

        // Some table does not have trends
        if (stat.rowsCountTrend) {
          var cumulativeCountTrend = [];
          // Caclulate the cumulative trend
          _.reduce(stat.rowsCountTrend, function(memo, trend, idx) {
            memo += trend;
            cumulativeCountTrend.push(memo);

            // Update the total cumulative trend
            if (totalCumulativeTrends[idx]) {
              totalCumulativeTrends[idx] += memo;
            } else {
              totalCumulativeTrends[idx] = memo
            }

            return memo;
          }, 0);

          // Replace the the trend by the cumulative
          stat.rowsCountTrend = cumulativeCountTrend;
        }
      });

      $scope.total.rowsCountTrend = totalCumulativeTrends;

      // Update the view
      $scope.stats = stats;
      $scope.currentStats = stats.slice(0, $scope.top);
      $scope.loading = false;
    });
  }
});

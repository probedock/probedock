angular.module('probedock.orgTopStatsWidget').directive('orgTopStatsWidget', function() {
  return {
    restrict: 'E',
    controller: 'OrgTopStatsWidgetCtrl',
    templateUrl: '/templates/widgets/org-top-stats/stats.template.html',
    scope: {
      top: '=?'
    }
  };
}).controller('OrgTopStatsWidgetCtrl', function(api, $scope, orgs) {
  _.defaults($scope, {
    params: {
      top: $scope.top ? $scope.top : 5
    },
    loading: true
  });

  fetchStats();

  function fetchStats() {
    $scope.loading = true;

    return api({
      url: '/platformManagement/orgStats',
      params: $scope.params
    }).then(function(response) {
      if (response.data) {
        var orgsStats = response.data.organizations;

        // Keep the total without organizations and udpate the trend to have cumulative trend
        var total = _.omit(response.data, 'organizations');
        var totalCumulativeTrends = [];
        _.reduce(total.resultsTrend, function(memo, trend) {
          memo += trend;
          totalCumulativeTrends.push(memo);
          return memo;
        }, 0);
        total.resultsTrend = totalCumulativeTrends;

        // Calculate the cumulative trends and the proportion of results
        _.each(orgsStats, function(stat) {
          var cumulativeTrends = [];

          _.reduce(stat.resultsTrend, function(memo, trend) {
            memo += trend;
            cumulativeTrends.push(memo);
            return memo;
          }, 0);

          stat.resultsTrend = cumulativeTrends;
          stat.resultsProp = stat.resultsCount / total.resultsCount * 100;
        });

        // Calculate the total for the top n organizations with the trends corresponding to them
        $scope.topStats = _.reduce(orgsStats, function(memo, orgStats) {
          memo.payloadsCount += orgStats.payloadsCount;
          memo.projectsCount += orgStats.projectsCount;
          memo.testsCount += orgStats.testsCount;
          memo.resultsCount += orgStats.resultsCount;
          memo.resultsProp += orgStats.resultsProp;

          // Cumulative trends for the top n organizations
          _.each(orgStats.resultsTrend, function(trend, idx) {
            memo.resultsTrend[idx] += trend;
          });

          return memo;
        }, {
          payloadsCount: 0, projectsCount: 0, testsCount:0, resultsCount: 0, resultsProp: 0,
          resultsTrend: _.map(new Array(orgsStats[0].resultsTrend.length), function(item) { return 0; })
        });

        $scope.total = total;
        $scope.stats = orgsStats;
        $scope.loading = false;
      }

      $scope.started = true;
    });
  }
});

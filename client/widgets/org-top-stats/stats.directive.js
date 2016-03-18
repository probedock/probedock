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
        $scope.stats = response.data.organizations;
        $scope.total = _.omit(response.data, 'organizations');

        $scope.topStats = _.reduce(response.data.organizations, function(memo, orgStats) {
          memo.payloadsCount += orgStats.payloadsCount;
          memo.projectsCount += orgStats.projectsCount;
          memo.testsCount += orgStats.testsCount;
          memo.resultsCount += orgStats.resultsCount;
          return memo;
        }, { payloadsCount: 0, projectsCount: 0, testsCount:0, resultsCount: 0 });

        $scope.loading = false;
      }

      $scope.started = true;
    });
  }
});

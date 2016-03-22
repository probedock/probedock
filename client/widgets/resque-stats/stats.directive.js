angular.module('probedock.resqueStatsWidget').directive('resqueStatsWidget', function() {
  return {
    restrict: 'E',
    controller: 'ResqueStatsWidgetCtrl',
    templateUrl: '/templates/widgets/resque-stats/stats.template.html'
  };
}).controller('ResqueStatsWidgetCtrl', function(api, $scope, orgs) {
  orgs.addAuthFunctions($scope);

  _.defaults($scope, {
    loading: true
  });

  fetchStats();

  function fetchStats() {
    $scope.loading = true;

    return api({
      url: '/platformManagement/resqueStats'
    }).then(function(response) {
      if (response.data) {
        $scope.resqueStats = response.data;
      }

      $scope.loading = false;
    });
  }
});

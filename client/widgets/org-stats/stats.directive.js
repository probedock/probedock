angular.module('probedock.orgStatsWidget').directive('orgStatsWidget', function() {
  return {
    restrict: 'E',
    controller: 'OrgStatsWidgetCtrl',
    templateUrl: '/templates/widgets/org-stats/stats.template.html',
    scope: {
      organization: '='
    }
  };
}).controller('OrgStatsWidgetCtrl', function(api, $scope, orgs) {
  orgs.addAuthFunctions($scope);

  _.defaults($scope, {
    params: {
      organizationId: $scope.organization.id
    },
    loading: true
  });

  $scope.$watch('params', function(value) {
    if (!_.isEmpty(value)) {
      fetchStats();
    }
  }, true);

  fetchStats();

  function fetchStats() {
    $scope.loading = true;

    return api({
      url: '/platformManagement/orgStats',
      params: $scope.params
    }).then(function(response) {
      if (response.data) {
        $scope.stats = [];

        _.each([ 'payloads', 'projects', 'tests', 'results' ], function(name) {
          var stat = {
            name: name,
            rowsCount: response.data.organization[name + 'Count'],
            proportion: response.data.organization[name + 'Count'] / response.data[name + 'Count'] * 100
          };

          if ($scope.currentUserIs('admin')) {
            stat.total = response.data[name + 'Count'];
          }

          $scope.stats.push(stat);
        });

        $scope.stats = _.sortBy($scope.stats, 'rowsCount');

        $scope.loading = false;
      }

      $scope.started = true;
    });
  }
});

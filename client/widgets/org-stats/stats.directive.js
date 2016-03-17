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

        // Prepare the data to show in a table way
        _.each([ 'payloads', 'projects', 'tests', 'results' ], function(name) {
          var stat = {
            name: name,
            rowsCount: response.data.organizations[0][name + 'Count'],
            proportion: response.data.organizations[0][name + 'Count'] / response.data[name + 'Count'] * 100
          };

          // Add the total only if super-admin
          if ($scope.currentUserIs('admin')) {
            stat.total = response.data[name + 'Count'];
          }

          $scope.stats.push(stat);
        });

        // Apply a filter on the total if the user is super-admin
        if ($scope.currentUserIs('admin')) {
          $scope.stats = _.sortBy($scope.stats, function(stat) { return -stat.total; });
        } else {
          $scope.stats = _.sortBy($scope.stats, function(stat) { return -stat.rowsCount; });
        }

        $scope.loading = false;
      }

      $scope.started = true;
    });
  }
});

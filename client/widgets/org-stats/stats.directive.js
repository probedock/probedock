angular.module('probedock.orgStatsWidget').directive('orgStatsWidget', function() {
  return {
    restrict: 'E',
    controller: 'OrgStatsWidgetCtrl',
    templateUrl: '/templates/widgets/org-stats/stats.template.html',
    scope: {
      organization: '=?'
    }
  };
}).controller('OrgStatsWidgetCtrl', function(api, $scope, orgs) {
  orgs.addAuthFunctions($scope);

  _.defaults($scope, {
    params: {
      organization: $scope.organization
    },
    loading: false
  });

  $scope.$watch('params', function(newParams) {
    if (!_.isUndefined(newParams.organization)) {
      console.log('here', newParams)
      fetchStats();
    }
  }, true);

  if ($scope.params.organization) {
    console.log('there', $scope.params)
    fetchStats();
    $scope.started = true;
  }

  function fetchStats() {
    $scope.loading = true;

    return api({
      url: '/platformManagement/orgStats',
      params: {
        organizationId: $scope.params.organization.id
      }
    }).then(function(response) {
      if (response.data.organizations[0]) {
        $scope.org = response.data.organizations[0];
        $scope.stats = [];

        // Prepare the data to show in a table way
        _.each([ 'payloads', 'projects', 'tests', 'results' ], function(name) {
          var stat = {
            name: name,
            rowsCount: response.data.organizations[0][name + 'Count'],
            proportion: response.data.organizations[0][name + 'Count'] / response.data[name + 'Count'] * 100
          };

          // Store results trend
          if (name == 'results') {
            // Cumulative trends for the organization
            var cumulativeTrend = [];
            _.reduce(response.data.organizations[0].resultsTrend, function(memo, trend) {
              memo += trend;
              cumulativeTrend.push(memo);
              return memo;
            }, 0);
            stat.resultsTrend = cumulativeTrend;

            // Cumulative trends for the total
            var totalCumulativeTrend = [];
            _.reduce(response.data.resultsTrend, function(memo, trend) {
              memo += trend;
              totalCumulativeTrend.push(memo);
              return memo;
            }, 0);
            stat.totalResultsTrend = totalCumulativeTrend;
          }

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
    });
  }
});

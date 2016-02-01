angular.module('probedock.dashboard', [ 'probedock.api', 'probedock.orgs', 'probedock.reports' ])

  .controller('DashboardCtrl', function(api, orgs, $scope, $stateParams) {

    orgs.forwardData($scope);

    $scope.orgIsActive = function() {
      return $scope.currentOrganization && $scope.currentOrganization.projectsCount && $scope.currentOrganization.membershipsCount;
    };

    $scope.gettingStarted = false;

    api({
      url: '/reports',
      params: {
        pageSize: 1,
        organizationName: $stateParams.orgName
      }
    }).then(function(res) {
      if (!res.pagination().total) {
        $scope.gettingStarted = true;
      }
    });
  })

  .controller('DashboardHeaderCtrl', function(orgs, $scope, $state, $stateParams) {

    var modal;
    $scope.currentState = $state.current.name;

    $scope.$on('$stateChangeSuccess', function(event, toState) {

      $scope.currentState = toState.name;

      if (toState.name == 'org.dashboard.default.edit') {
        modal = orgs.openForm($scope);

        modal.result.then(function() {
          $state.go('^', {}, { inherit: true });
        }, function(reason) {
          if (reason != 'stateChange') {
            $state.go('^', {}, { inherit: true });
          }
        });
      }
    });
  })

  .controller('DashboardTagCloudCtrl', function(api, $scope, $stateParams) {

    fetchTags().then(showTags);

    function fetchTags() {
      return api({
        url: '/tags',
        params: {
          organizationName: $stateParams.orgName
        }
      });
    }

    function showTags(response) {
      $scope.tags = _.reduce(response.data, function(memo, tag) {

        memo.push({
          text: tag.name,
          weight: tag.testsCount
        });

        return memo;
      }, []);
    }
  })

  .directive('recentActivity', function() {
    return {
      restrict: 'E',
      controller: 'RecentActivityCtrl',
      controllerAs: 'ctrl',
      templateUrl: '/templates/recent-activity.html',
      scope: {
        organization: '='
      }
    };
  })

  .controller('RecentActivityCtrl', function(api, $scope) {

    $scope.$watch('organization', function(value) {
      if (value) {
        fetchReports();
      }
    });

    function fetchReports() {
      return api({
        url: '/reports',
        params: {
          pageSize: 5,
          organizationId: $scope.organization.id,
          withRunners: 1,
          withProjects: 1,
          withProjectVersions: 1,
          withCategories: 1
        }
      }).then(showReports);
    }

    function showReports(response) {
      $scope.reports = response.data;
    }
  })

;

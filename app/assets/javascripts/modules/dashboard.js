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

  .directive('newTestsLineChart', function() {
    return {
      restrict: 'E',
      controller: 'NewTestsLineChartCtrl',
      templateUrl: '/templates/new-tests-line-chart.html',
      scope: {
        organization: '='
      }
    };
  })

  .controller('NewTestsLineChartCtrl', function(api, $scope) {

    $scope.chart = {
      data: [],
      labels: [],
      params: {
        projectIds: [],
        userIds: []
      },
      options: {
        pointHitDetectionRadius: 5,
        tooltipTemplate: '<%= value %> new tests on <%= label %>'
      }
    };

    $scope.projectChoices = [];

    // TODO: replace users by contributors
    $scope.userChoices = [];

    $scope.$watch('organization', function(value) {
      if (value) {
        fetchMetrics();
        fetchProjectChoices();
        fetchUserChoices();
      }
    });

    var ignoreChartParams = true;
    $scope.$watch('chart.params', function(value) {
      if (value && !ignoreChartParams) {
        fetchMetrics();
      }

      ignoreChartParams = false;
    }, true);

    function fetchProjectChoices() {
      api({
        url: '/projects',
        params: {
          organizationId: $scope.organization.id
        }
      }).then(function(res) {
        $scope.projectChoices = res.data;
      });
    }

    function fetchUserChoices() {
      api({
        url: '/users',
        params: {
          organizationId: $scope.organization.id
        }
      }).then(function(res) {
        $scope.userChoices = res.data;
      });
    }

    function fetchMetrics() {
      return api({
        url: '/metrics/newTests',
        params: _.extend({}, $scope.chart.params, {
          organizationId: $scope.organization.id
        })
      }).then(showMetrics);
    }

    function showMetrics(response) {
      if (!response.data.length) {
        return;
      }

      var series = [];
      $scope.chart.data = [ series ];
      $scope.chart.labels.length = 0;

      _.each(response.data, function(data) {
        $scope.chart.labels.push(moment(data.date).format('DD.MM'));
        series.push(data.testsCount);
      });
    }
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

  .controller('DashboardLatestReportsCtrl', function(api, $scope, $stateParams) {

    api({
      url: '/reports',
      params: {
        pageSize: 8,
        organizationName: $stateParams.orgName,
        withRunners: 1
      }
    }).then(showReports);

    function showReports(response) {
      $scope.reports = response.data;
    }
  })

;

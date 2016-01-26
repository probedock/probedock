angular.module('probedock.testsByWeekWidget', [ 'probedock.api' ])
  .directive('testsByWeekWidget', function() {
    return {
      restrict: 'E',
      controller: 'TestsByWeekChartCtrl',
      templateUrl: '/templates/tests-by-week-widget.html',
      scope: {
        organization: '=',
        project: '='
      }
    };
  })

  .controller('TestsByWeekChartCtrl', function(api, $scope) {

    $scope.chart = {
      data: [],
      labels: [],
      params: {
        projectIds: [],
        userIds: []
      },
      options: {
        pointHitDetectionRadius: 5,
        tooltipTemplate: '<%= value %> tests on <%= label %>',

        /*
         * Fix for space issue in the Y axis labels
         * see: https://github.com/nnnick/Chart.js/issues/729
         * see: http://stackoverflow.com/questions/26498171/how-do-i-prevent-the-scale-labels-from-being-cut-off-in-chartjs
         */
        scaleLabel: function(object) {
          return '  ' + object.value;
        }
      }
    };

    $scope.projectChoices = [];
    $scope.userChoices = [];

    $scope.$watch('organization', function(value) {
      if (value) {
        fetchMetrics();
        fetchUserChoices();

        if (!$scope.project) {
          fetchProjectChoices();
        }
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
      if ($scope.project) {
        $scope.chart.params.projectIds = [$scope.project.id];
      }

      return api({
        url: '/metrics/testsByWeek',
        params: _.extend({}, $scope.chart.params, {
          organizationId: $scope.organization.id,
          nbWeeks: $scope.nbWeeks || 10
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
      $scope.totalCount = response.data[response.data.length - 1].testsCount;

      _.each(response.data, function(data) {
        $scope.chart.labels.push(moment(data.date).format('DD.MM.YYYY'));
        series.push(data.testsCount);
      });
    }
  })
;

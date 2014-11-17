angular.module('rox.dashboard', ['rox.reports'])

  .controller('DashboardNewTestMetricsCtrl', ['ApiService', '$scope', function($api, $scope) {

    fetchMetrics().then(showMetrics);

    $scope.chartFormatX = function(timestamp) {
      return moment(timestamp).format('ll');
    };

    $scope.chartTooltip = function(key, x, y, e, graph) {
      return y + ' new tests on ' + moment(new Date(x)).format('ll');
    };

    function fetchMetrics() {
      return $api.http({
        method: 'GET',
        url: '/api/metrics/newTests'
      });
    }

    function showMetrics(response) {

      if (!response.data.length) {
        $scope.chartData = [];
        return;
      }

      $scope.chartData = [
        {
          key: 'New Tests',
          values: _.reduce(response.data, function(memo, data) {
            memo.push([ new Date(data.date).getTime(), data.testsCount ]);
            return memo;
          }, [])
        }
      ];
    }
  }])

  .controller('DashboardTagCloudCtrl', ['ApiService', '$scope', function($api, $scope) {

    fetchTags().then(showTags);

    function fetchTags() {
      return $api.http({
        method: 'GET',
        url: '/api/tags'
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
  }])

  .controller('DashboardLatestReportsCtrl', ['ApiService', 'ReportService', '$scope', function($api, $reportService, $scope) {

    fetchLatestReports().then(showReports);

    function fetchLatestReports() {
      return $api.http({
        method: 'GET',
        url: '/api/reports',
        params: {
          pageSize: 8,
          'sort[]': [ 'createdAt desc' ]
        }
      });
    }

    function showReports(response) {
      $scope.reports = response.data;
    }
  }])

;

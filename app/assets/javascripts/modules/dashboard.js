angular.module('rox.dashboard', ['rox.reports'])

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

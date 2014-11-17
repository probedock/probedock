angular.module('rox.dashboard', ['rox.reports'])

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

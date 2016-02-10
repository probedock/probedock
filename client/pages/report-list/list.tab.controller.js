angular.module('probedock.reportListPage').controller('ReportListTabCtrl', function(api, $scope) {

  api({
    url: '/reports/' + $scope.reportTab.id
  }).then(function(res) {
    $scope.report = res.data;
    $scope.reportTab.loading = false;
  });

  $scope.reportTime = function() {
    if (!$scope.report) {
      return 'Loading...';
    }

    var reportTime = moment($scope.report.startedAt);

    if (reportTime.isAfter(moment().startOf('day'))) {
      reportTime = reportTime.format('HH:mm');
    } else if (reportTime.isAfter(moment().startOf('year'))) {
      reportTime = reportTime.format('MMM D HH:mm');
    } else {
      reportTime = reportTime.format('MMM D YYYY HH:mm');
    }

    var runners = _.first(_.pluck($scope.report.runners, 'name'), 3);
    return reportTime + ' by ' + runners.join(', ');
  };
});

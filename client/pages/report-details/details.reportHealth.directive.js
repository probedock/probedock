angular.module('probedock.reportDetailsPage').directive('reportHealth', function() {
  return {
    restrict: 'E',
    controller: 'ReportHealthCtrl',
    templateUrl: '/templates/pages/report-details/details.reportHealth.template.html',
    scope: {
      report: '=',
      healthFilters: '='
    }
  };
}).controller('ReportHealthCtrl', function(api, $sce, $scope) {

  fetchHealth().then(showHealth);

  function fetchHealth() {
    return api({
      url: '/reports/' + $scope.report.id + '/health'
    });
  }

  function showHealth(response) {
    $scope.healthHtml = $sce.trustAsHtml(response.data.html);
  }
});

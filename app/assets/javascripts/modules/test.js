angular.module('probedock.test', [ 'probedock.api', 'probedock.forms', 'probedock.utils' ])

  .controller('TestCtrl', function (api, orgs, $scope, $stateParams) {
    orgs.forwardData($scope);

    api({
      url: '/tests/' + $stateParams.testId,
      params: {
        withProject: 1,
        withContributions: 1
      }
    }).then(function(response) {
      $scope.test = response.data;
    });
  })
;

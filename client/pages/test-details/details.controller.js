angular.module('probedock.testDetailsPage').controller('TestDetailsPageCtrl', function (api, orgs, $scope, $stateParams) {
  orgs.forwardData($scope);

  api({
    url: '/tests/' + $stateParams.id,
    params: {
      withProject: 1,
      withContributions: 1,
      withScm: 1
    }
  }).then(function(response) {
    $scope.test = response.data;
  });
});

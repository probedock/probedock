angular.module('probedock.test', [ 'probedock.api', 'probedock.forms', 'probedock.utils' ])

  .controller('TestCtrl', function (api, forms, orgs, projects, $scope, $state, $stateParams) {
    orgs.forwardData($scope);

    api({
      url: '/tests/' + $stateParams.testId,
      params: {
        organizationId: $stateParams.orgId,
        withProject: 1,
        withContributions: 1
      }
    })
    .then(function(response) {
      $scope.test = response.data;

      orgs
        .getOrganization(response.data.project.organizationId)
        .then(function(organization) {
          $scope.organization = organization;
        });
    });
  })

;

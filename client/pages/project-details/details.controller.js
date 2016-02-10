angular.module('probedock.projectDetailsPage').controller('ProjectDetailsPageCtrl', function(api, orgs, $scope, $state, $stateParams) {
  orgs.forwardData($scope);

  api({
    url: '/projects',
    params: {
      organizationName: $stateParams.orgName,
      name: $stateParams.projectName
    }
  }).then(function(response) {
    if (response.data[0]) {
      project = response.data[0];

      return api({
        url: '/reports',
        params: {
          projectId: project.id
        }
      }).then(function(response) {
        $scope.project = _.extend(project, {
          reportsCount: response.pagination().filteredTotal
        });
      });
    }
  });
});

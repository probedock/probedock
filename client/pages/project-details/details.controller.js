angular.module('probedock.projectDetailsPage').controller('ProjectDetailsPageCtrl', function(api, orgs, projectEditModal, $scope, $state, states, $stateParams) {
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

      registerOnEditProject(project);

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

  /**
   * Will open the edit project modal if the state is or changes to "org.projects.show.edit".
   */
  function registerOnEditProject(project) {
    states.onState($scope, 'org.projects.show.edit', function(toState) {
      var modal = projectEditModal.open($scope, { project: project });

      modal.result.then(function(updatedProject) {
        $scope.project = updatedProject;
        $state.go('^', {}, { inherit: true });
      }, function(reason) {
        if (reason != 'stateChange') {
          $state.go('^', {}, { inherit: true });
        }
      });
    });
  }
});

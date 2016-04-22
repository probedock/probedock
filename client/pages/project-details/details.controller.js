angular.module('probedock.projectDetailsPage').controller('ProjectDetailsPageCtrl', function(api, orgs, projectEditModal, routeOrgName, $scope, $state, states, $stateParams) {
  orgs.forwardData($scope);

  api({
    url: '/projects',
    params: {
      organizationName: routeOrgName,
      name: $stateParams.projectName
    }
  }).then(function(response) {
    if (response.data[0]) {
      // Make sure the reportsCount is always defined
      $scope.project = _.extend(response.data[0], { reportsCount: null });

      registerOnEditProject();

      // Retrieve the number of reports for this project
      return api({
        url: '/reports',
        params: {
          projectId: $scope.project.id
        }
      }).then(function(response) {
        // Update the number of reports
        $scope.project.reportsCount = response.pagination().filteredTotal;
      });
    }
  });

  /**
   * Will open the edit project modal if the state is or changes to "org.projects.show.edit".
   */
  function registerOnEditProject() {
    states.onStateChangeSuccess($scope, 'org.projects.show.edit', function(toState) {
      var modal = projectEditModal.open($scope, { project: $scope.project });

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

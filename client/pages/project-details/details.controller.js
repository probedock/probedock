angular.module('probedock.projectDetailsPage').controller('ProjectDetailsPageCtrl', function(api, orgs, projectEditModal, $scope, $state, $stateParams) {
  orgs.forwardData($scope);

  $scope.$on('$stateChangeSuccess', function(event, toState) {
    if (toState.name.match(/^org\.projects\.show\.edit$/)) {
      var modal = projectEditModal.open($scope);

      modal.result.then(function(project) {
        $scope.project = project;
        $state.go('^', {}, { inherit: true });
      }, function(reason) {
        if (reason != 'stateChange') {
          $state.go('^', {}, { inherit: true });
        }
      });
    }
  });

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

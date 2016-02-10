angular.module('probedock.projectListPage').controller('ProjectListPageCtrl', function(api, orgs, projectEditModal, $scope, $state, $stateParams) {
  orgs.forwardData($scope);

  // FIXME: recursively fetch all projects
  api({
    url: '/projects',
    params: {
      organizationName: $stateParams.orgName,
      pageSize: 25
    }
  }).then(showProjects);

  $scope.$on('$stateChangeSuccess', function(event, toState) {
    if (toState.name.match(/^org.projects.list.(?:new|edit)$/)) {
      modal = projectEditModal.open($scope);

      modal.result.then(function(project) {
        api.pushOrUpdate($scope.projects, project);
        $state.go('^', {}, { inherit: true });
      }, function(reason) {
        if (reason != 'stateChange') {
          $state.go('^', {}, { inherit: true });
        }
      });
    }
  });

  $scope.orderProject = function(project) {
    return (project.displayName || project.name).toLowerCase();
  };

  function showProjects(response) {
    $scope.projects = response.data;
  }
});

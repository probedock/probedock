angular.module('probedock.projectListPage').controller('ProjectListPageCtrl', function(api, orgs, projectEditModal, routeOrgName, $scope, $state, states) {
  orgs.forwardData($scope);

  $scope.$watch('projectName', function(value, oldValue) {
    if (value || value !== oldValue) {
      $scope.$emit('projects.filtered');
    }
  });

  states.onState($scope, /^org.projects.list.(?:new|edit)$/, function(toState, toParams) {
    var modal = projectEditModal.open($scope, { projectId: toParams.id });

    modal.result.then(function(project) {
      api.pushOrUpdate($scope.projects, project);
      $state.go('^', {}, { inherit: true });
    }, function(reason) {
      if (reason != 'stateChange') {
        $state.go('^', {}, { inherit: true });
      }
    });
  });

  $scope.orderProject = function(project) {
    return (project.displayName || project.name).toLowerCase();
  };

  $scope.page = 0;
  $scope.projects = [];

  $scope.fetchProjects = function() {
    if ($scope.disableScroll) {
      return;
    }

    $scope.loading = true;
    $scope.disableScroll = true;

    $scope.page++;
    var params = {
      organizationName: routeOrgName,
      pageSize: 10,
      page: $scope.page
    };

    api({
      url: '/projects',
      params: params
    }).then(function(response) {
      $scope.projects = $scope.projects.concat(response.data);
      $scope.total = response.pagination().total;
      $scope.disableScroll = $scope.page >= response.pagination().numberOfPages;
      $scope.loading = false;
    });
  };

  $scope.isVisible = function(project) {
    if ($scope.projectName) {
      var displayName = project.displayName ? project.displayName.toLowerCase() : project.name.toLowerCase();
      var search = $scope.projectName.toLowerCase();
      return displayName.indexOf(search) > -1;
    } else {
      return true;
    }
  };
});

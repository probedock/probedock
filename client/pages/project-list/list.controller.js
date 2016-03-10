angular.module('probedock.projectListPage').controller('ProjectListPageCtrl', function(api, orgs, projectEditModal, $scope, $state, $stateParams) {
  orgs.forwardData($scope);
  //
  //fetchProjects();
  //
  $scope.$watch('projectName', function(value, oldValue) {
    if (value || value !== oldValue) {
      //fetchProjects();
      filterProjects();
    }
  });

  $scope.$on('$stateChangeSuccess', function(event, toState, toStateParams) {
    if (toState.name.match(/^org.projects.list.(?:new|edit)$/)) {
      modal = projectEditModal.open($scope, { projectId: toStateParams.id });

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
    return (project.project.displayName || project.project.name).toLowerCase();
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
      organizationName: $stateParams.orgName,
      pageSize: 1,
      page: $scope.page
    };

    api({
      url: '/projects',
      params: params
    }).then(function(response) {
      $scope.projects = $scope.projects.concat(prepareProjects(response.data));
      $scope.total = response.pagination().total;
      $scope.disableScroll = $scope.page >= response.pagination().numberOfPages;
      $scope.loading = false;
    });
  };

  function prepareProjects(projects) {
    return _.map(projects, function(project) {
      return {
        show:  isProjectShowable(project),
        project: project
      }
    });
  }

  function filterProjects() {
    _.each($scope.projects, function(project) {
      project.show = isProjectShowable(project.project);
    });
  }

  function isProjectShowable(project) {
    if ($scope.projectName) {
      var displayName = project.displayName ? project.displayName.toLowerCase() : '';
      var search = $scope.projectName.toLowerCase();
      return displayName.indexOf(search) > -1;
    } else {
      return true;
    }
  }
});

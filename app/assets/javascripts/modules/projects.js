angular.module('probe-dock.projects', ['probe-dock.api'])

  .controller('ProjectsCtrl', function(api, $scope, $stateParams) {

    $scope.newProject = {};

    api.http({
      method: 'GET',
      url: '/api/projects',
      params: {
        organizationName: $stateParams.orgName,
        pageSize: 25
      }
    }).then(showProjects);

    $scope.createProject = function(form) {
      api.http({
        method: 'POST',
        url: '/api/projects',
        data: $scope.newProject
      }).then(_.partial(onProjectCreated, form));
    }

    function showProjects(response) {
      $scope.projects = response.data;
    }

    function onProjectCreated(form, response) {
      form.$setPristine();
      $scope.newProject = {};
      $scope.projects.unshift(response.data);
      $scope.lastCreatedProject = response.data;
    };
  })

  .controller('ProjectCtrl', function(api, $scope) {

    $scope.edit = function() {
      $scope.editedProject = _.pick($scope.project, 'name', 'description');
    };

    $scope.cancelEdit = function() {
      delete $scope.editedProject;
      $scope.editProjectForm.$setPristine();
    };

    $scope.save = function() {
      api.http({
        method: 'PATCH',
        url: '/api/projects/' + $scope.project.id,
        data: $scope.editedProject
      }).then(onProjectSaved);
    }

    function onProjectSaved(response) {
      $scope.editProjectForm.$setPristine();
      _.extend($scope.project, $scope.editedProject);
      delete $scope.editedProject;
    };
  });

;

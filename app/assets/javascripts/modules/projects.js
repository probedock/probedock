angular.module('rox.projects', ['rox.api'])

  .controller('ProjectsCtrl', ['ApiService', '$scope', function($api, $scope) {

    $scope.newProject = {};

    $api.http({
      method: 'GET',
      url: '/api/projects',
      params: {
        pageSize: 25,
        'sort[]': [ 'name asc' ]
      }
    }).then(showProjects);

    $scope.createProject = function(form) {
      $api.http({
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
  }])

  .controller('ProjectCtrl', ['ApiService', '$scope', function($api, $scope) {

    $scope.edit = function() {
      $scope.editedProject = _.pick($scope.project, 'name', 'description');
    };

    $scope.cancelEdit = function() {
      delete $scope.editedProject;
      $scope.editProjectForm.$setPristine();
    };

    $scope.save = function() {
      $api.http({
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
  }]);

;

angular.module('rox.projects', ['rox.api'])

  .controller('ProjectsController', ['ApiService', '$scope', function($api, $scope) {

    $scope.newProject = {};

    $api.http({
      method: 'GET',
      url: '/api/projects'
    }).then(showProjects);

    function showProjects(response) {
      $scope.projects = response.data;
    }

    $scope.createProject = function() {
      $api.http({
        method: 'POST',
        url: '/api/projects',
        data: $scope.newProject
      }).then(onProjectCreated);
    };

    function onProjectCreated(response) {
      $scope.projects.unshift(response.data);
    };
  }])

;

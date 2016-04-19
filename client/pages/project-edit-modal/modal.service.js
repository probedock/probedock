angular.module('probedock.projectEditModal').service('projectEditModal', function($modal) {
  return {
    /**
     * Opens a modal to create or edit a project.
     *
     * * If called with a `project` option, it will edit that project.
     * * If called with a `projectId` option, it will fetch that project from the API and edit it.
     * * Otherwise, it will create a new project.
     *
     * Returns a promise that will be resolved with the created/edited project, or rejected if canceled.
     * If the cancelation is due to a state change, the error will be "stateChange".
     */
    open: function($scope, options) {
      options = _.extend({}, options);

      var scope = $scope.$new();
      _.extend(scope, _.pick(options, 'project', 'projectId'));

      var modal = $modal.open({
        templateUrl: '/templates/pages/project-edit-modal/modal.template.html',
        controller: 'ProjectEditModalCtrl',
        scope: scope,
        size: 'lg'
      });

      $scope.$on('$stateChangeStart', function() {
        modal.dismiss('stateChange');
      });

      return modal;
    }
  };
}).controller('ProjectEditModalCtrl', function(api, forms, $modalInstance, orgs, $scope) {

  $scope.repoUrlPatternPlaceholder = '{{ repoUrl }}/example/{{ commit }}/{{ filePath }}#{{ fileLine }}';

  $scope.project = $scope.project || {};
  $scope.editedProject = {};

  if ($scope.project && $scope.project.id) {
    // Edit the specified project.
    reset();
  } else if ($scope.projectId) {
    // Fetch and edit a project.
    api({
      url: '/projects/' + $scope.projectId
    }).then(function(res) {
      $scope.project = res.data;
      reset();
    });
  } else {
    // Create a new project.
    $scope.project.organizationId = orgs.currentOrganization.id;
    reset();
  }

  $scope.reset = reset;
  $scope.changed = function() {
    return !forms.dataEquals($scope.project, $scope.editedProject);
  };

  $scope.save = function() {

    var method = 'POST',
        url = '/projects';

    if ($scope.project.id) {
      method = 'PATCH';
      url += '/' + $scope.project.id;
    }

    $scope.editedProject.name = api.slugify($scope.editedProject.displayName);

    api({
      method: method,
      url: url,
      data: $scope.editedProject
    }).then(function(res) {

      // TODO: move this to projects service
      orgs.updateOrganization(_.extend(orgs.currentOrganization, { projectsCount: orgs.currentOrganization.projectsCount + 1 }));

      $modalInstance.close(res.data);
    });
  };

  $scope.setCustomRepoUrlPattern = function(enabled) {
    $scope.customRepoUrlPattern = !!enabled;
  };

  $scope.$watch('project', function(value) {
    if (value) {
      $scope.customRepoUrlPattern = !!value.repoUrlPattern;
    }
  });

  $scope.$watch('editedProject.repoUrlPattern', function(value, oldValue) {
    if (value && !oldValue) {
      $scope.customRepoUrlPattern = true;
    }
  });

  $scope.$watch('customRepoUrlPattern', function(value, oldValue) {
    if (!value && oldValue) {
      delete $scope.editedProject.repoUrlPattern;
    }
  });

  function reset() {
    $scope.editedProject = angular.copy($scope.project);
  }
});

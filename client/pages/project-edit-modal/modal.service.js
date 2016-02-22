angular.module('probedock.projectEditModal').service('projectEditModal', function($modal) {
  return {
    open: function($scope) {
      var modal = $modal.open({
        templateUrl: '/templates/pages/project-edit-modal/modal.template.html',
        controller: 'ProjectEditModalCtrl',
        scope: $scope
      });

      $scope.$on('$stateChangeStart', function() {
        modal.dismiss('stateChange');
      });

      return modal;
    }
  };
}).controller('ProjectEditModalCtrl', function(api, forms, $modalInstance, orgs, $scope, $stateParams) {

  $scope.project = {};
  $scope.editedProject = {};

  if ($stateParams.id) {
    api({
      url: '/projects/' + $stateParams.id
    }).then(function(res) {
      $scope.project = res.data;
      reset();
    });
  } else {
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

  function reset() {
    $scope.editedProject = angular.copy($scope.project);
  }
});

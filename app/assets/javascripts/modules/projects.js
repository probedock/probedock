angular.module('probe-dock.projects', [ 'probe-dock.api', 'probe-dock.forms', 'probe-dock.utils' ])

  .factory('projects', function(api, eventUtils, $modal) {

    var service = eventUtils.service({
      openForm: function($scope) {

        var modal = $modal.open({
          templateUrl: '/templates/project-modal.html',
          controller: 'ProjectFormCtrl',
          scope: $scope
        });

        $scope.$on('$stateChangeStart', function() {
          modal.dismiss('stateChange');
        });

        return modal;
      }
    });

    return service;
  })

  .controller('ProjectFormCtrl', function(api, forms, $modalInstance, projects, $scope, $stateParams) {

    $scope.project = {};
    $scope.editedProject = {};

    if ($stateParams.id) {
      api({
        url: '/api/projects/' + $stateParams.id
      }).then(function(res) {
        $scope.project = res.data;
        reset();
      });
    }

    $scope.reset = reset;
    $scope.changed = function() {
      return !forms.dataEquals($scope.project, $scope.editedProject);
    };

    $scope.save = function() {

      var method = 'POST',
          url = '/api/projects';

      if ($scope.project.id) {
        method = 'PATCH';
        url += '/' + $scope.project.id;
      }

      api({
        method: method,
        url: url,
        data: $scope.editedProject
      }).then(function(res) {
        $modalInstance.close(res.data);
      });
    };

    function reset() {
      $scope.editedProject = angular.copy($scope.project);
    }
  })

  .controller('ProjectsCtrl', function(api, projects, $scope, $state, $stateParams) {

    $scope.newProject = {};

    api({
      method: 'GET',
      url: '/api/projects',
      params: {
        organizationName: $stateParams.orgName,
        pageSize: 25
      }
    }).then(showProjects);

    $scope.$on('$stateChangeSuccess', function(event, toState) {
      if (toState.name == 'org.projects.edit') {
        modal = projects.openForm($scope);

        modal.result.then(function() {
          $state.go('^', {}, { inherit: true });
        }, function(reason) {
          if (reason != 'stateChange') {
            $state.go('^', {}, { inherit: true });
          }
        });
      }
    });

    $scope.createProject = function(form) {
      api({
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
      api({
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
  })

  .filter('projectName', function() {
    return function(input) {
      return input.displayName || input.name;
    };
  })

  .directive('uniqueProjectName', function(api, $q) {
    return {
      require: 'ngModel',
      link: function(scope, elm, attrs, ctrl) {

        ctrl.$asyncValidators.uniqueProjectName = function(modelValue, viewValue) {

          // If the name is blank or is the same as the previous name,
          // then there can be no name conflict with another organization.
          if (_.isBlank(modelValue) || (_.isPresent(scope.project.name) && modelValue == scope.project.name)) {
            return $q.when();
          }

          return api({
            url: '/api/projects',
            params: {
              name: modelValue,
              organizationId: scope.project.organizationId,
              pageSize: 1,
            }
          }).then(function(res) {
            // value is invalid if a matching organization is found (length is 1)
            return $q[res.data.length ? 'reject' : 'when']();
          }, function() {
            // consider value valid if uniqueness cannot be verified
            return $q.when();
          });
        };
      }
    };
  })

;

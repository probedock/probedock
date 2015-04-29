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

  .controller('ProjectFormCtrl', function(api, forms, $modalInstance, orgs, projects, $scope, $stateParams) {

    $scope.project = {};
    $scope.editedProject = {};

    if ($stateParams.id) {
      api({
        url: '/api/projects/' + $stateParams.id
      }).then(function(res) {
        $scope.project = res.data;
        reset();
      });
    } else {
      $scope.project.organizationId = orgs.currentOrganization.id
      reset();
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

  .controller('ProjectsCtrl', function(api, forms, orgs, projects, $scope, $state, $stateParams) {

    $scope.project = {
      organizationId: orgs.currentOrganization.id
    };

    reset();

    api({
      method: 'GET',
      url: '/api/projects',
      params: {
        organizationName: $stateParams.orgName,
        pageSize: 25
      }
    }).then(showProjects);

    $scope.$on('$stateChangeSuccess', function(event, toState) {
      if (toState.name.match(/^org.projects.(?:new|edit)$/)) {
        modal = projects.openForm($scope);

        modal.result.then(function(project) {
          $scope.projects.push(project);
          $state.go('^', {}, { inherit: true });
        }, function(reason) {
          if (reason != 'stateChange') {
            $state.go('^', {}, { inherit: true });
          }
        });
      }
    });

    $scope.reset = reset;
    $scope.changed = function() {
      return !forms.dataEquals($scope.project, $scope.editedProject);
    };

    $scope.save = function() {
      api({
        method: 'POST',
        url: '/api/projects',
        data: $scope.editedProject
      }).then(onProjectCreated);
    }

    function showProjects(response) {
      $scope.projects = response.data;
    }

    function onProjectCreated(res) {
      $scope.projects.push(res.data);
    };

    function reset() {
      $scope.editedProject = angular.copy($scope.project);
      if ($scope.projectForm) {
        $scope.projectForm.$setPristine();
      }
    }
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

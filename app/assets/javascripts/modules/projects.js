angular.module('probedock.projects', [ 'probedock.api', 'probedock.forms', 'probedock.utils' ])

  .factory('projects', function(api, eventUtils, $modal, $q) {

    var currentOrg = null;

    var service = eventUtils.service({

      projects: [],

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
      },

      forwardProjects: function($scope) {

        setScopeProjects();

        service.forward($scope, 'refresh', { prefix: 'projects.' });
        $scope.$on('projects.refresh', setScopeProjects);

        function setScopeProjects() {
          $scope.projects = service.projects;
        }
      },

      fetchProjects: function(orgId) {
        if (orgId != currentOrg) {
          currentOrg = orgId;
          service.projects = [];
          return fetchProjectsRecursive();
        } else {
          return $q.when(service.projects);
        }

        function fetchProjectsRecursive(page) {
          page = page || 1;

          return api({
            url: '/projects',
            params: {
              organizationId: orgId,
              page: page,
              pageSize: 25
            }
          }).then(function(res) {

            service.projects = service.projects.concat(res.data);

            if (res.pagination().hasMorePages) {
              return fetchProjectsRecursive(++page);
            } else {
              service.emit('refresh', service.projects);
              return service.projects;
            }
          });
        }
      }
    });

    return service;
  })

  .controller('ProjectFormCtrl', function(api, forms, $modalInstance, orgs, projects, $scope, $stateParams) {

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
      $scope.project.organizationId = orgs.currentOrganization.id
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
  })

  .controller('ProjectsCtrl', function(api, forms, orgs, projects, $scope, $state, $stateParams) {

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
        modal = projects.openForm($scope);

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
  })

  .filter('projectName', function() {
    return function(input) {
      return input ? input.displayName || input.name : '';
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
            url: '/projects',
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

  .controller('ProjectPanelCtrl', function(api, $scope) {
    if ($scope.project && $scope.project.lastReportId) {
      fetchReport();
    }

    function fetchReport() {
      return api({
        url: '/reports/' + $scope.project.lastReportId,
        params: {
          withProjectCountsFor: $scope.project.id
        }
      }).then(function(res) {
        return showChart(res.data);
      });
    }

    function showChart(report) {

      var numberPassed = report.projectCounts.passedResultsCount - report.projectCounts.inactivePassedResultsCount,
          numberInactive = report.projectCounts.inactiveResultsCount,
          numberFailed = report.projectCounts.resultsCount - numberPassed - numberInactive;

      $scope.stateChart = {
        labels: [ 'passed', 'failed', 'inactive' ],
        data: [ numberPassed, numberFailed, numberInactive ],
        colors: [ '#62c462', '#ee5f5b', '#fbb450' ]
      };
    }
  })

  .directive('projectTeamWidget', function() {
    return {
      restrict: 'E',
      controller: 'ProjectTeamWidgetCtrl',
      templateUrl: '/templates/project-team-widget.html',
      scope: {
        project: '='
      }
    };
  })

  .controller('ProjectTeamWidgetCtrl', function(api, $scope) {
    $scope.$watch('project', function(project) {
      if (project) {
        fetchContributions();
      }
    });

    function fetchContributions() {
      api({
        url: '/metrics/contributions',
        params: {
          projectId: $scope.project.id
        }
      }).then(function(res) {
        $scope.contributions = res.data;
      });
    }
  })

;

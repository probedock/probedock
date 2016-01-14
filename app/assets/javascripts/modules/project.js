angular.module('probedock.project', [ 'probedock.api', 'probedock.forms', 'probedock.utils' ])

  .controller('ProjectCtrl', function (api, forms, orgs, projects, $scope, $state, $stateParams) {
    orgs.forwardData($scope);

    api({
      url: '/projects',
      params: {
        organizationName: $stateParams.orgName,
        name: $stateParams.projectName
      }
    })
    .then(function (response) {
      if (response.data[0]) {
        project = response.data[0];

        return api({
          url: '/reports',
          params: {
            organizationName: $stateParams.orgName,
            projectId: project.id
          }
        })
        .then(function (response) {
          $scope.project = _.extend(project, {
            reportsCount: response.pagination().filteredTotal
          });
        });
      }
    });
  })

  .directive('projectRecentActivity', function() {
    return {
      restrict: 'E',
      controller: 'ProjectRecentActivityCtrl',
      controllerAs: 'ctrl',
      templateUrl: '/templates/project-recent-activity.html',
      scope: {
        organization: '=',
        project: '='
      }
    };
  })

  .controller('ProjectRecentActivityCtrl', function(api, $scope) {

    $scope.$watch('project', function(value) {
      if (value) {
        fetchReports();
      }
    });

    function fetchReports() {
      return api({
        url: '/reports',
        params: {
          pageSize: 5,
          organizationId: $scope.organization.id,
          projectId: $scope.project.id,
          withRunners: 1,
          withProjects: 1,
          withProjectVersions: 1,
          withCategories: 1
        }
      }).then(showReports);
    }

    function showReports(response) {
      $scope.reports = response.data;
    }
  })

;

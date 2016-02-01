angular.module('probedock.projectSelect', [ 'probedock.api' ])
  .directive('projectSelect', function() {
    return {
      restrict: 'E',
      controller: 'ProjectSelectCtrl',
      templateUrl: '/templates/project-select.html',
      scope: {
        organization: '=',
        modelObject: '=',
        modelProperty: '@',
        prefix: '@'
      }
    };
  })

  .controller('ProjectSelectCtrl', function(api, $scope) {
    if (!$scope.prefix) {
      throw new Error("The prefix attribute on project-select directive is not set.");
    }

    if (!$scope.modelProperty) {
      $scope.modelProperty = "projectIds";
    }

    $scope.projectChoices = [];

    $scope.$watch('organization', function(value) {
      if (value) {
        fetchProjectChoices();
      }
    });

    function fetchProjectChoices() {
      api({
        url: '/projects',
        params: {
          organizationId: $scope.organization.id
        }
      }).then(function(res) {
        $scope.projectChoices = res.data;
      });
    }
  })
;

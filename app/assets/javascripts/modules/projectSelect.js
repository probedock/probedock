angular.module('probedock.projectSelect', [ 'probedock.api' ])
  .directive('projectSelect', function() {
    return {
      restrict: 'E',
      controller: 'ProjectSelectCtrl',
      templateUrl: '/templates/project-select.html',
      scope: {
        organization: '=',
        project: '=',
        parentData: '=modelObject',
        modelProperty: '=?'
      }
    };
  })

  .controller('ProjectSelectCtrl', function(api, $scope) {
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

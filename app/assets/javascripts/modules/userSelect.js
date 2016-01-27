angular.module('probedock.userSelect', [ 'probedock.api' ])
  .directive('userSelect', function() {
    return {
      restrict: 'E',
      controller: 'UserSelectCtrl',
      templateUrl: '/templates/user-select.html',
      scope: {
        organization: '=',
        parentData: '=modelObject',
        modelProperty: '=?'
      }
    };
  })

  .controller('UserSelectCtrl', function(api, $scope) {
    if (!$scope.modelProperty) {
      $scope.modelProperty = "userIds";
    }

    $scope.userChoices = [];

    $scope.$watch('organization', function(value) {
      if (value) {
        fetchUserChoices();
      }
    });

    function fetchUserChoices() {
      api({
        url: '/users',
        params: {
          organizationId: $scope.organization.id
        }
      }).then(function(res) {
        $scope.userChoices = res.data;
      });
    }
  })
;

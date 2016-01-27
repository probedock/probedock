angular.module('probedock.userChoiceSelect', [ 'probedock.api' ])
  .directive('userChoiceSelect', function() {
    return {
      restrict: 'E',
      controller: 'UserChoiceSelectCtrl',
      templateUrl: '/templates/user-choice-select.html',
      scope: {
        organization: '=',
        parentData: '=modelObject',
        modelProperty: '=?'
      }
    };
  })

  .controller('UserChoiceSelectCtrl', function(api, $scope) {
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

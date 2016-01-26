angular.module('probedock.userChoiceCtrl', [ 'probedock.api' ])
  .directive('userChoiceCtrl', function() {
    return {
      restrict: 'E',
      controller: 'UserChoiceCtrl',
      templateUrl: '/templates/user-choice-ctrl.html',
      scope: {
        organization: '=',
        update: '='
      }
    };
  })

  .controller('UserChoiceCtrl', function(api, $scope) {
    $scope.model = {
      userIds: []
    };
    $scope.userChoices = [];

    $scope.$watch('organization', function(value) {
      if (value) {
        fetchUserChoices();
      }
    });

    $scope.$watch('model.userIds', function(value) {
      if (value && $scope.update) {
        $scope.update(value);
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

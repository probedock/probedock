angular.module('probedock.userChoiceSelect', [ 'probedock.api' ])
  .directive('userChoiceSelect', function() {
    return {
      restrict: 'E',
      controller: 'UserChoiceSelectCtrl',
      templateUrl: '/templates/user-choice-select.html',
      scope: {
        organization: '=',
        onUpdate: '&'
      }
    };
  })

  .controller('UserChoiceSelectCtrl', function(api, $scope) {
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
      if (value && $scope.onUpdate) {
        $scope.onUpdate({ userIds: value });
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

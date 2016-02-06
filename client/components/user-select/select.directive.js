angular.module('probedock.userSelect').directive('userSelect', function() {
  return {
    restrict: 'E',
    controller: 'UserSelectCtrl',
    templateUrl: '/templates/components/user-select/select.template.html',
    scope: {
      organization: '=',
      modelObject: '=',
      modelProperty: '@',
      prefix: '@'
    }
  };
}).controller('UserSelectCtrl', function(api, $scope) {
  if (!$scope.prefix) {
    throw new Error("The prefix attribute on user-select directive is not set.");
  }

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
});

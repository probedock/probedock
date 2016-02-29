angular.module('probedock.userSelect').directive('userSelect', function() {
  return {
    restrict: 'E',
    controller: 'UserSelectCtrl',
    templateUrl: '/templates/components/user-select/select.template.html',
    scope: {
      organization: '=',
      modelObject: '=',
      modelProperty: '@',
      prefix: '@',
      placeholder: '@',
      label: '@',
      noLabel: '='
    }
  };
}).controller('UserSelectCtrl', function(api, $scope) {
  if (!$scope.prefix) {
    throw new Error("The prefix attribute on user-select directive is not set.");
  }

  if (!$scope.modelProperty) {
    $scope.modelProperty = "userIds";
  }

  if (_.isUndefined($scope.noLabel)) {
    $scope.noLabel = false;
  }

  if (_.isUndefined($scope.label)) {
    $scope.label = 'Filter by user';
  }

  if (_.isUndefined($scope.placeholder)) {
    $scope.placeholder = 'All users';
  }

  $scope.userChoices = [];

  $scope.$watch('organization', function(value) {
    if (value) {
      $scope.fetchUserChoices();
    }
  });

  $scope.fetchUserChoices = function(userName) {
    var params = {
      organizationId: $scope.organization.id
    };

    if (userName) {
      params.search = userName;
    }

    api({
      url: '/users',
      params: params
    }).then(function(res) {
      $scope.userChoices = res.data;
    });
  }
});

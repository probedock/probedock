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
      noLabel: '@',
      multiple: '=?',
      allowClear: '=?',
      label: '@'
    }
  };
}).controller('UserSelectCtrl', function(api, $scope) {
  if (!$scope.prefix) {
    throw new Error("The prefix attribute on user-select directive is not set.");
  }

  if (_.isUndefined($scope.multiple)) {
    $scope.multiple = true;
  }

  if (_.isUndefined($scope.allowClear)) {
    $scope.allowClear = true;
  }

  if (!$scope.modelProperty) {
    if ($scope.multiple) {
      $scope.modelProperty = 'userIds';
    } else {
      $scope.modelProperty = 'userId';
    }
  }

  if (_.isUndefined($scope.label)) {
    $scope.label = 'Filter by user';
  }

  if (_.isUndefined($scope.noLabel)) {
    $scope.noLabel = false;
  }

  $scope.userChoices = [];

  $scope.getPlaceholder = function() {
    if (!_.isUndefined($scope.placeholder)) {
      return $scope.placeholder;
    } else {
      return 'All users';
    }
  };

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

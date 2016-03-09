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
      multiple: '=?',
      allowClear: '=?',
      label: '@',
      noLabel: '=?'
    }
  };
}).controller('UserSelectCtrl', function(api, $scope) {
  if (!$scope.prefix) {
    throw new Error("The prefix attribute on user-select directive is not set.");
  }

  _.defaults($scope, {
    modelProperty: $scope.multiple ? 'userIds' : 'userId',
    placeholder: 'All users',
    label: 'Filter by user',
    allowClear: true,
    multiple: false,
    noLabel: false,
    userChoices: []
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

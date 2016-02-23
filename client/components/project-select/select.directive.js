angular.module('probedock.projectSelect').directive('projectSelect', function() {
  return {
    restrict: 'E',
    controller: 'ProjectSelectCtrl',
    templateUrl: '/templates/components/project-select/select.template.html',
    scope: {
      organization: '=',
      modelObject: '=',
      modelProperty: '@',
      prefix: '@',
      placeholder: '@',
      noLabel: '@'
    }
  };
}).controller('ProjectSelectCtrl', function(api, $scope) {
  if (!$scope.prefix) {
    throw new Error("The prefix attribute on project-select directive is not set.");
  }

  if (!$scope.modelProperty) {
    $scope.modelProperty = "projectIds";
  }

  if (_.isUndefined($scope.noLabel)) {
    $scope.noLabel = false;
  }

  $scope.projectChoices = [];

  $scope.getPlaceholder = function() {
    if ($scope.placeholder) {
      return $scope.placeholder;
    } else {
      return 'All projects';
    }
  };

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
});

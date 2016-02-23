angular.module('probedock.categorySelect').directive('categorySelect', function() {
  return {
    restrict: 'E',
    controller: 'CategorySelectCtrl',
    templateUrl: '/templates/components/category-select/select.template.html',
    scope: {
      organization: '=',
      modelObject: '=',
      modelProperty: '@',
      prefix: '@',
      placeholder: '@',
      noLabel: '@'
    }
  };
}).controller('CategorySelectCtrl', function(api, $scope) {
  if (!$scope.prefix) {
    throw new Error("The prefix attribute on category-select directive is not set.");
  }

  if (_.isUndefined($scope.noLabel)) {
    $scope.noLabel = false;
  }

  if (!$scope.modelProperty) {
    $scope.modelProperty = "categoryNames";
  }

  $scope.categoryChoices = [];

  $scope.getPlaceholder = function() {
    if ($scope.placeholder) {
      return $scope.placeholder;
    } else {
      return 'All categories';
    }
  };

  $scope.$watch('organization', function(value) {
    if (value) {
      fetchChoices();
    }
  });

  function fetchChoices() {
    api({
      url: '/categories',
      params: {
        organizationId: $scope.organization.id
      }
    }).then(function(res) {
      $scope.categoryChoices = res.data;
    });
  }
});

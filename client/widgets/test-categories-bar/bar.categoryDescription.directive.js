angular.module('probedock.testCategoriesBarWidget').directive('testCategoriesBarCategoryDescription', function() {
  return {
    restrict: 'E',
    controller: 'TestCategoriesBarCategoryDescriptionCtrl',
    templateUrl: '/templates/widgets/test-categories-bar/bar.categoryDescription.template.html',
    scope: {
      category: '=',
      categoryIndex: '='
    }
  };
}).controller('TestCategoriesBarCategoryDescriptionCtrl', function($scope, testCategoriesBar) {
  $scope.getColor = testCategoriesBar.getColor;

  $scope.getTestsCountDescription = function() {
    if ($scope.category.testsCount == 1) {
      return '1 test';
    } else {
      return $scope.category.testsCount + ' tests';
    }
  };
});

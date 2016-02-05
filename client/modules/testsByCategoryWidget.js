angular.module('probedock.testsByCategoryWidget', [ 'probedock.api' ])

  .factory('testsByCategory', function() {

    var colors = [ '#337AB7', '#5BC0DE', '#9966ff', '#D9534F', '#00cc99', '#ff9933', '#F0AD4E', '#99cc00', '#ccccff', '#339966' ];

    return {
      getColor: function(index) {
        return colors[index % (colors.length - 1)];
      }
    };
  })

  /**
   * Widget to display the categories in an organization or project along with the
   * number of tests for each category.
   */
  .directive('testsByCategoryWidget', function() {
    return {
      restrict: 'E',
      controller: 'TestsByCategoryBarsCtrl',
      templateUrl: '/templates/tests-by-category-widget.html',
      scope: {
        organization: '=',
        project: '=',
        // The maximum number of categories that will be explicitly displayed.
        // If there are more categories, the last ones will all be grouped
        // under "Others".
        maxNbCategories: '=?'
      }
    };
  })

  .controller('TestsByCategoryBarsCtrl', function(api, $scope, testsByCategory) {

    _.extend($scope, {
      testsByCategory: [],
      maxNbCategories: $scope.maxNbCategories || 5,
      params: {
        projectIds: [],
        userIds: []
      }
    });

    $scope.$watch('organization', function(value) {
      if (value) {
        fetchMetrics();
      }
    });

    var ignoreChartParams = true;
    $scope.$watch('params', function(value) {
      if (value && !ignoreChartParams) {
        if (!$scope.latestVersion && $scope.params.projectVersion) {
          $scope.latestVersion = $scope.params.projectVersion;
        }

        fetchMetrics();
      }

      ignoreChartParams = false;
    }, true);

    $scope.dropCloseState = false;

    $scope.beforeClose = function() {
      if ($scope.dropCloseState) {
        $scope.dropCloseState = false;
        return true;
      }
      return false;
    };

    $scope.closeFilters = function() {
      $scope.dropCloseState = true;
      $scope.$broadcast('closeDrop');
    };

    $scope.resetFilters = function() {
      $scope.params = {
        projectIds: [],
        userIds: [],
        projectVersion: $scope.latestVersion
      }
    };

    $scope.getColor = testsByCategory.getColor;

    function fetchMetrics() {
      if ($scope.project && !$scope.params.projectVersion) {
        $scope.params.projectIds = [$scope.project.id];
      }

      var params = {
        userIds: $scope.params.userIds
      };

      if ($scope.params.projectVersion) {
        params.projectVersionId = $scope.params.projectVersion.id;
      } else {
        params.projectIds = $scope.params.projectIds;
      }

      return api({
        url: '/metrics/testsByCategories',
        params: _.extend({}, params, {
          organizationId: $scope.organization.id
        })
      }).then(showMetrics);
    }

    function showMetrics(response) {

      // Compute the total number of tests across all categories (including tests with no category)
      var total = _.reduce(response.data.categories, function(memo, category) {
        return memo + category.testsCount;
      }, response.data.noCategoryTestsCount);

      // Copy the array of categories with the number of tests
      var categories = _.clone(response.data.categories);

      // If there are tests without a category, the number is given as a property outside of the array,
      // so we transform it into a category object and add it to the array.
      if (response.data.noCategoryTestsCount > 0) {
        categories.push({
          name: 'No category',
          testsCount: response.data.noCategoryTestsCount
        });
      }

      // Sort the categories by descending number of tests
      categories = _.sortBy(categories, function(category) {
        return -category.testsCount;
      });

      // Compute the percentages for each category
      _.each(categories, function(category) {
        category.percentage = 100 / total * category.testsCount;
      });

      // If the number of categories is greater than the maximum we want to display, group the last ones under "Others"
      if (categories.length > $scope.maxNbCategories) {

        // Extract the other categories from the array
        var otherCategories = categories.splice($scope.maxNbCategories - 1, categories.length - $scope.maxNbCategories + 1);

        // Compute the total number of test for the other categories
        var otherCategoriesTotal = _.reduce(otherCategories, function(memo, category) {
          return memo + category.testsCount;
        }, 0);

        // Add a category object representing the other categories
        categories.push({
          name: 'Others',
          testsCount: otherCategoriesTotal,
          percentage: 100 / total * otherCategoriesTotal,
          others: otherCategories
        });
      }

      $scope.categories = categories;
    }
  })

  .directive('testsByCategoryWidgetDescription', function() {
    return {
      restrict: 'E',
      controller: 'TestsByCategoryDescriptionCtrl',
      templateUrl: '/templates/tests-by-category-widget-description.html',
      scope: {
        category: '=',
        categoryIndex: '='
      }
    };
  })

  .controller('TestsByCategoryDescriptionCtrl', function($scope, testsByCategory) {
    $scope.getColor = testsByCategory.getColor;

    $scope.getTestsCountDescription = function() {
      if ($scope.category.testsCount == 1) {
        return '1 test';
      } else {
        return $scope.category.testsCount + ' tests';
      }
    };
  })

;

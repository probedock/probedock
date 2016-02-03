angular.module('probedock.testsByCategoryWidget', [ 'probedock.api' ])
  .directive('testsByCategoryWidget', function() {
    return {
      restrict: 'E',
      controller: 'TestsByCategoryBarsCtrl',
      templateUrl: '/templates/tests-by-category-widget.html',
      scope: {
        organization: '=',
        project: '=',
        nbCategories: '=?'
      }
    };
  })

  .controller('TestsByCategoryBarsCtrl', function(api, $scope) {

    _.extend($scope, {
      testsByCategory: [],
      colors: [ '#337AB7', '#5BC0DE', '#9966ff', '#D9534F', '#00cc99', '#ff9933', '#F0AD4E', '#99cc00', '#ccccff', '#339966' ],
      nbCategories: $scope.nbCategories || 4,
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

    $scope.getColor = function(index) {
      return $scope.colors[index % ($scope.colors.length - 1)];
    };

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
      // Sum the number of tests for all the categories
      var total = _.reduce(response.data.categories, function(memo, category) {
        return memo + category.testsCount;
      }, response.data.noCategoryTestsCount);

      // Prepare the data for sorting
      var testsByCategoryRaw = _.clone(response.data.categories);

      // Show the number of tests without a category only if there more than one test
      if (response.data.noCategoryTestsCount > 0) {
        testsByCategoryRaw.push({
          name: 'No category',
          testsCount: response.data.noCategoryTestsCount
        });
      }

      // Sort the metrics by testsCount
      var testsByCategorySorted = _.sortBy(testsByCategoryRaw, function(testByCategory) {
        return -testByCategory.testsCount;
      });

      // Split the categories to show and the categories to group under "other"
      var slicing = testsByCategorySorted.length > $scope.nbCategories ? $scope.nbCategories : testsByCategorySorted.length - 1;
      var retainedCategories = testsByCategorySorted.slice(0, slicing);
      var otherCategories = testsByCategorySorted.slice(slicing);

      var testsByCategory = [];

      // Calculate the percentage of the shown categories
      _.each(retainedCategories, function(retainedCategory) {
        testsByCategory.push(_.extend(retainedCategory, {
          percent: 100 / total * retainedCategory.testsCount
        }));
      });

      // If necessary calculate the number of tests for remaining categories and the corresponding percentage
      if (!_.isEmpty(otherCategories)) {
        var othersArray = [];
        var others = _.reduce(otherCategories, function(memo, otherCategory) {
          othersArray.push(_.extend(otherCategory, {
            percent: 100 / total * otherCategory.testsCount
          }));
          return memo + otherCategory.testsCount;
        }, 0);

        // Add others only if there is at least one test
        if (others > 0) {
          testsByCategory.push({
            name: 'Others',
            testsCount: others,
            percent: 100 / total * others,
            others: othersArray
          });
        }
      }

      $scope.testsByCategory = testsByCategory;
    }
  })
;

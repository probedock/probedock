angular.module('probedock.testDataLabel').directive('testDataLabel', function() {
  return {
    restrict: 'E',
    controller: 'TestDataLabelCtrl',
    templateUrl: '/templates/components/test-data-label/label.template.html',
    transclude: true,
    replace: true,
    scope: {
      label: '=',
      type: '@',
      modelProperty: '@'
    },
    link: function($scope, element, attributes, ctrl, transclude) {
      // Acts as fallback when no transcluded element is present. In Angular 1.5+, fallback
      // element is available through the directive usage in template.
      transclude(function(transcludeEl) {
        if (transcludeEl.length > 0) {
          $scope.show = false;
        }
      });
    }
  };
}).directive('categoryLabels', function() {
  return {
    category: 'E',
    template: '<test-data-label ng-if="categories.length > 0" ng-repeat="category in categories" type="info" label="category" />',
    replace: true,
    scope: {
      categories: '='
    }
  };
}).directive('tagLabels', function() {
  return {
    category: 'E',
    template: '<test-data-label ng-if="tags.length > 0" ng-repeat="tag in tags" type="default" label="tag" />',
    replace: true,
    scope: {
      tags: '='
    }
  };
}).directive('ticketLabels', function() {
  return {
    category: 'E',
    template: '<test-data-label ng-if="tickets.length > 0" ng-repeat="ticket in tickets" type="warning" label="ticket" />',
    replace: true,
    scope: {
      tickets: '='
    }
  };
})
.controller('TestDataLabelCtrl', function($scope) {
  $scope.show = true;

  $scope.getTypeClass = function() {
    return $scope.type ? 'label-' + $scope.type : '';
  };

  $scope.getText = function() {
    if (_.isString($scope.label)) {
      return $scope.label;
    }
    else if (!_.isUndefined($scope.modelProperty)) {
      return $scope.label[$scope.modelProperty];
    }
  };
});
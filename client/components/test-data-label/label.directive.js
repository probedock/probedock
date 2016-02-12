function linkFn(type) {
  return function($scope) {
    if (type) {
      $scope.type = type;
    }
  };
}

function labelDirectiveFactory(attributeName, type) {
  return {
    restrict: 'E',
    templateUrl: '/templates/components/test-data-label/label.template.html',
    controller: 'TestDataLabelCtrl',
    replace: true,
    scope: {
      label: '=' + attributeName
    },
    link: linkFn(type)
  }
}

function labelsDirectiveFactory(collectionName, attributeName) {
  return {
    restrict: 'E',
    template: '<' + attributeName + '-label ng-repeat="' + attributeName + ' in collection" ' + attributeName + '="' + attributeName + '" />',
    replace: true,
    scope: {
      collection: '=' + collectionName
    }
  };
}

angular.module('probedock.testDataLabel').directive('testDataLabel', function() {
  return {
    restrict: 'E',
    controller: 'TestDataLabelCtrl',
    templateUrl: '/templates/components/test-data-label/label.template.html',
    replace: true,
    scope: {
      label: '=',
      type: '@'
    },
    link: linkFn()
  };
}).directive('projectAndVersionLabel', function() {
  return {
    restrict: 'E',
    templateUrl: '/templates/components/test-data-label/project-and-version-label.template.html',
    replace: true,
    scope: {
      organization: '=',
      project: '=',
      projectVersion: '='
    }
  };
})

.directive('categoryLabel', function() { return labelDirectiveFactory('category', 'info'); })
.directive('ticketLabel', function() { return labelDirectiveFactory('ticket', 'warning'); })
.directive('tagLabel', function() { return labelDirectiveFactory('tag', 'default'); })

.directive('categoryLabels', function() { return labelsDirectiveFactory('categories', 'category') })
.directive('tagLabels', function() { return labelsDirectiveFactory('tags', 'tag')})
.directive('ticketLabels', function() { return labelsDirectiveFactory('tickets', 'ticket') })

.controller('TestDataLabelCtrl', function($scope) {
  $scope.getTypeClass = function() {
    return $scope.type ? 'label-' + $scope.type : '';
  };
});
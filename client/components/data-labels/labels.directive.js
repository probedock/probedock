angular.module('probedock.dataLabels').directive('simpleLabel', function() {
  return {
    restrict: 'E',
    controller: 'DataLabelCtrl',
    templateUrl: '/templates/components/data-labels/data-label.template.html',
    replace: true,
    scope: {
      label: '=',
      type: '@'
    },
    link: linkFn()
  };
}).directive('projectVersionLabel', function() {
  return {
    restrict: 'E',
    templateUrl: '/templates/components/data-labels/project-version-label.template.html',
    replace: true,
    scope: {
      organization: '=',
      project: '=',
      projectVersion: '=',
      versionOnly: '=',
      linkable: '='
    },
    link: function($scope) {
      if (_.isUndefined($scope.linkable)) {
        $scope.linkable = true;
      }
    }
  };
}).directive('testKeyLabel', function() {
  return {
    restrict: 'E',
    scope: {
      key: '=',
      copied: '=',
      onCopied: '&'
    },
    template: '<div class="data-label test-key-label" ng-class="{copied: copied}" clip-copy="key.key || key" clip-click="onCopied({ key: key })" tooltip="Click to copy">{{ key.key || key }}</div>'
  };
}).directive('apiIdLabel', function() {
  return {
    restrict: 'E',
    scope: {
      apiId: '='
    },
    template: '<div class="data-label api-id-label" clip-copy="apiId" tooltip="Click to copy">{{ apiId }}</div>'
  };
})

.directive('categoryLabel', function() { return labelDirectiveFactory('category', 'info'); })
.directive('ticketLabel', function() { return labelDirectiveFactory('ticket', 'warning'); })
.directive('tagLabel', function() { return labelDirectiveFactory('tag', 'default'); })

.directive('categoryLabels', function() { return labelsDirectiveFactory('categories', 'category') })
.directive('tagLabels', function() { return labelsDirectiveFactory('tags', 'tag')})
.directive('ticketLabels', function() { return labelsDirectiveFactory('tickets', 'ticket') })

.controller('DataLabelCtrl', function($scope) {
  $scope.getTypeClass = function() {
    return $scope.type ? 'label-' + $scope.type : '';
  };
});

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
    templateUrl: '/templates/components/data-labels/data-label.template.html',
    controller: 'DataLabelCtrl',
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
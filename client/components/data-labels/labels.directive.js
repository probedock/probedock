angular.module('probedock.dataLabels').directive('simpleLabel', function() {
  return {
    restrict: 'E',
    controller: 'DataLabelCtrl',
    templateUrl: '/templates/components/data-labels/data-label.template.html',
    replace: true,
    scope: {
      label: '@',
      type: '@'
    }
  };
}).directive('projectVersionLabel', function() {
  return {
    restrict: 'E',
    controller: 'ProjectVersionLabelCtrl',
    templateUrl: '/templates/components/data-labels/project-version-label.template.html',
    replace: true,
    scope: {
      organization: '=',
      project: '=',
      projectVersion: '=',
      versionOnly: '=?',
      linkable: '=?',
      truncate: '=?'
    }
  };
}).directive('sourceUrlLabel', function() {
  return {
    restrict: 'E',
    controller: 'SourceUrlLabelCtrl',
    templateUrl: '/templates/components/data-labels/source-url-label.template.html',
    replace: true,
    scope: {
      url: '=',
      scm: '=?',
      tooltipPlacement: '@'
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
      apiId: '=',
      copyTooltip: '@'
    },
    controller: function($scope) {
      if (_.isUndefined($scope.copyTooltip)) {
        $scope.copyTooltip = 'Click to copy';
      }
    },
    template: '<div class="data-label api-id-label" clip-copy="apiId" tooltip="{{ copyTooltip }}">{{ apiId }}</div>'
  };
})

.directive('categoryLabel', function() { return labelDirectiveFactory('category', 'info'); })
.directive('ticketLabel', function() { return labelDirectiveFactory('ticket', 'warning'); })
.directive('tagLabel', function() { return labelDirectiveFactory('tag', 'default'); })

.directive('categoryLabels', function() { return labelsDirectiveFactory('categories', 'category'); })
.directive('tagLabels', function() { return labelsDirectiveFactory('tags', 'tag'); })
.directive('ticketLabels', function() { return labelsDirectiveFactory('tickets', 'ticket'); })

.controller('DataLabelCtrl', function($scope) {
  $scope.getTypeClass = function() {
    return $scope.type ? 'label-' + $scope.type : '';
  };
})
.controller('ProjectVersionLabelCtrl', function($scope, projectNameFilter) {
  if (_.isUndefined($scope.linkable)) {
    $scope.linkable = true;
  }

  if (_.isUndefined($scope.truncate)) {
    $scope.truncate = true;
  }

  if (!$scope.labelSize) {
    $scope.labelSize = 30;
  }

  $scope.getTooltip = function () {
    return $scope.versionOnly ? $scope.projectVersion : projectNameFilter($scope.project) + ' ' + $scope.projectVersion;
  };

  $scope.tooltipEnabled = function () {
    return $scope.truncate && $scope.getTooltip().length > $scope.labelSize;
  };

  $scope.getLabel = function () {
    var str = $scope.getTooltip();

    if ($scope.truncate && str.length > $scope.labelSize) {
      var halfLength = $scope.labelSize / 2;

      return str.substr(0, 0 + halfLength) + '...' + str.substr(str.length - halfLength);
    } else {
      return str;
    }
  };
})
.controller('SourceUrlLabelCtrl', function($scope) {
  _.defaults($scope, {
    tooltipPlacement: 'top'
  });

  $scope.isDirty = function() {
    // Check if SCM data are present
    if ($scope.scm) {
      // Check if dirty is set
      if (!_.isUndefined($scope.scm.dirty)) {
        return $scope.scm.dirty;
      } else if (!_.isUndefined($scope.scm.remote)) { // Check if remote data are present to consider the commit as dirty or not
        if (!_.isUndefined($scope.scm.remote.behind)) { // Check if commit is behind remote
          return $scope.scm.remote.behind > 0;
        } else if (!_.isUndefined($scope.scm.remote.ahead)) { // Check if commit is ahead remote
          return $scope.scm.remote.ahead > 0;
        }
      }
    }

    // The commit is not behind/ahead remote or dirty (not commited...)
    return false;
  };

  $scope.getTooltip = function() {
    var tooltip = "Show source file.";

    // Add tooltip content if SCM data are present
    if ($scope.scm) {
      // Add dirty info if the dirty flag is set
      if (!_.isUndefined($scope.scm.dirty) && $scope.scm.dirty) {
        tooltip += " The test was probably run on a commit not pushed.";
      }

      // Add ahead/behind info if remote data are present
      if ($scope.scm.remote) {
        // Add ahead info if present
        if ($scope.scm.remote.ahead && $scope.scm.remote.ahead > 0) {
          tooltip += "The commit is ahead of " + $scope.scm.remote.ahead + " from remote.";
        }

        // Add behind info if present
        if ($scope.scm.remote.behind && $scope.scm.remote.behind > 0) {
          tooltip += "The commit is behind of " + $scope.scm.remote.behind + " from remote.";
        }
      }
    }

    return tooltip;
  };
});

function linkFn(type) {
  return function($scope) {
    if (!$scope.type) {
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

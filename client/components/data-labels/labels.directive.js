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
    controller: function($scope) {
      $scope.isBlank = function() {
        return _.isString($scope.key) ? _.isBlank($scope.key) : _.isBlank($scope.key.key);
      }
    },
    template: '<div class="data-label test-key-label" ng-if="!isBlank()" ng-class="{copied: copied}" clip-copy="key.key || key" clip-click="onCopied({ key: key })" uib-tooltip="Click to copy">{{ key.key || key }}</div>'
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

      $scope.isBlank = function() {
        return _.isBlank($scope.apiId);
      }
    },
    template: '<div class="data-label api-id-label" ng-if="!isBlank()" clip-copy="apiId" uib-tooltip="{{ copyTooltip }}">{{ apiId }}</div>'
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

  $scope.isBlank = function() {
    return _.isBlank($scope.label);
  }
})
.controller('ProjectVersionLabelCtrl', function($scope, projectNameFilter) {
  _.defaults($scope, {
    linkable: true,
    truncate: true,
    labelSize: 30
  });

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

  $scope.isNotPushed = function() {
    // Check if SCM data are present
    if ($scope.scm) {
      // Check if dirty is set (modifications not commited)
      if ($scope.scm.dirty) {
        return true;
      } else {
        // If remote data present and ahead info present and commit is ahead of remote, consider the commit not pushed on remote
        return !_.isUndefined($scope.scm.remote) && !_.isUndefined($scope.scm.remote.ahead) && $scope.scm.remote.ahead > 0;
      }
    }

    // The commit is pushed to remote or SCM data not available
    return false;
  };

  $scope.getTooltip = function() {

    var tooltip = "Show source file.";

    var warnings = [];

    if ($scope.scm) {

      // Warn the user that there were uncommitted local changes if the dirty flag is set.
      if (!_.isUndefined($scope.scm.dirty) && $scope.scm.dirty) {
        warnings.push('there were uncommitted local changes');
      }

      if ($scope.scm.remote) {

        // Warn the user that the commit was not pushed if scm.remote.ahead is present.
        if ($scope.scm.remote.ahead && $scope.scm.remote.ahead > 0) {
          warnings.push('the current commit was not pushed');
        }
      }
    }

    var numberOfWarnings = warnings.length;
    if (numberOfWarnings) {
      tooltip += ' ATTENTION! When the test was run: ';
      tooltip += warnings.join(', ');
      tooltip += '. The linked file might not yet exist or the line number could be incorrect.';
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

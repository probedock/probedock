angular.module('probedock.projectVersionSelect').directive('projectVersionSelect', function() {
  return {
    restrict: 'E',
    controller: 'ProjectVersionSelectCtrl',
    templateUrl: '/templates/components/project-version-select/select.template.html',
    //priority: -1,
    scope: {
      organization: '=',
      project: '=',
      modelObject: '=',
      modelProperty: '@',
      latestVersion: '=',
      prefix: '@',
      createNew: '=?',
      autoSelect: '=?',
      multiple: '@',
      placeholder: '@',
      noLabel: '@',
      uniqueBy: '@',
      extract: '@'
    }
  };
}).controller('ProjectVersionSelectCtrl', function(api, $scope) {
  if (!$scope.prefix) {
    throw new Error("The prefix attribute on project-version-select directive is not set.");
  }

  if (!$scope.modelProperty) {
    if ($scope.multiple) {
      $scope.modelProperty = 'projectVersionIds';
    } else {
      $scope.modelProperty = 'projectVersionId'
    }
  }

  if (_.isUndefined($scope.extract)) {
    $scope.extract = 'id';
  }

  if (_.isUndefined($scope.noLabel)) {
    $scope.noLabel = false;
  }

  $scope.config = {
    newVersion: false
  };

  $scope.projectVersionChoices = [];

  $scope.$watch('organization', function(value) {
    if (value) {
      $scope.fetchProjectVersionChoices();
    }
  });

  $scope.$watch('project', function(value) {
    if (value && !$scope.organization) {
      $scope.fetchProjectVersionChoices();
    }
  });

  $scope.$watch('config.newVersion', function(value) {
    if (value) {
      var previousVersion = $scope.modelObject[$scope.modelProperty];
      // create a new object if a new version is to be created
      $scope.modelObject[$scope.modelProperty] = {};
      // pre-fill it with either the previously selected version, or 1.0.0
      $scope.modelObject[$scope.modelProperty].name = previousVersion ? previousVersion.name : '1.0.0';
    } else if (value === false && $scope.projectVersionChoices.length && $scope.autoSelect) {
      // auto-select the first existing version when disabling creation of a new version
      $scope.modelObject[$scope.modelProperty] = $scope.projectVersionChoices[0];
    }
  });

  $scope.getPlaceholder = function() {
    if ($scope.placeholder) {
      return $scope.placeholder;
    } else if ($scope.latestVersion) {
      return "Latest version: " + $scope.latestVersion.name;
    } else if ($scope.multiple) {
      return 'All versions';
    } else {
      return null;
    }
  };

  $scope.fetchProjectVersionChoices = function(version) {
    var params = {};

    if ($scope.organization) {
      params.organizationId = $scope.organization.id;
    }

    if ($scope.project) {
      params.projectId = $scope.project.id;
    }

    if (version) {
      params.search = version;
    }

    api({
      url: '/projectVersions',
      params: params
    }).then(function(res) {
      if ($scope.uniqueBy) {
        $scope.projectVersionChoices = _.uniq(res.data, function(projectVersion) { return projectVersion[$scope.uniqueBy]; });
      } else {
        $scope.projectVersionChoices = res.data;
      }

      if ($scope.projectVersionChoices.length && $scope.autoSelect) {
        // if versions are found, automatically select the first one
        $scope.modelObject[$scope.modelProperty] = $scope.projectVersionChoices[0];
      } else if (!$scope.projectVersionChoices.length && $scope.createNew) {
        // if there are no existing versions and version creation is
        // enabled, automatically switch to the free input field
        $scope.config.newVersion = true;
      }
    });
  }
});

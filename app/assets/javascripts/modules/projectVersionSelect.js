angular.module('probedock.projectVersionSelect', [ 'probedock.api' ])
  .directive('projectVersionSelect', function() {
    return {
      restrict: 'E',
      controller: 'ProjectVersionSelectCtrl',
      templateUrl: '/templates/project-version-select.html',
      scope: {
        project: '=',
        modelObject: '=',
        modelProperty: '@',
        latestVersion: '=',
        prefix: '@',
        createNew: '=?',
        autoSelect: '=?'
      }
    };
  })

  .controller('ProjectVersionSelectCtrl', function(api, $scope) {
    if (!$scope.prefix) {
      throw new Error("The prefix attribute on project-version-select directive is not set.");
    }

    if (!$scope.modelProperty) {
      $scope.modelProperty = "projectVersion";
    }

    $scope.config = {
      newVersion: false
    };

    $scope.projectVersionChoices = [];

    $scope.$watch('project', function(value) {
      if (value) {
        fetchProjectVersionChoices();
      }
    });

    $scope.$watch('config.newVersion', function(value) {
      if (value && $scope.modelObject[$scope.modelProperty]) {
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
      if ($scope.latestVersion) {
        return "Latest version: " + $scope.latestVersion.name;
      } else {
        return null;
      }
    };

    function fetchProjectVersionChoices() {
      api({
        url: '/projectVersions',
        params: {
          projectId: $scope.project.id
        }
      }).then(function(res) {
        $scope.projectVersionChoices = res.data;

        if (res.data.length && $scope.autoSelect) {
          // if versions are found, automatically select the first one
          $scope.modelObject[$scope.modelProperty] = res.data[0];
        } else if (!res.data.length && $scope.createNew) {
          // if there are no existing versions and version creation is
          // enabled, automatically switch to the free input field
          $scope.config.newVersion = true;
        }
      });
    }
  })
;

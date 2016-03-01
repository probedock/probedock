angular.module('probedock.projectRepoIcon').directive('projectRepoIcon', function() {
  return {
    restrict: 'E',
    template: '<i class="{{ getClasses() }}" />',
    controller: 'ProjectRepoIconCtrl',
    scope: {
      project: '='
    }
  };
}).controller('ProjectRepoIconCtrl', function($scope) {
  $scope.getClasses = function() {
    var iconClass = 'fa-link';

    if ($scope.project.repoUrl.match(/^.*\/\/.*github.*\/.*$/)) {
      iconClass = 'fa-github-alt';
    } else if ($scope.project.repoUrl.match(/^.*\/\/.*bitbucket.*\/.*$/)) {
      iconClass = 'fa-bitbucket';
    }

    return 'fa ' + iconClass;
  };
});

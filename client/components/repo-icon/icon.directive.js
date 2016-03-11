angular.module('probedock.repoIcon').directive('repoIcon', function() {
  return {
    restrict: 'E',
    template: '<i class="{{ getClasses() }}" />',
    controller: 'RepoIconCtrl',
    scope: {
      url: '='
    }
  };
}).controller('RepoIconCtrl', function($scope) {
  $scope.getClasses = function() {
    var iconClass = 'fa-link';

    if ($scope.url.match(/^.*\/\/.*github.*\/.*$/)) {
      iconClass = 'fa-github-alt';
    } else if ($scope.url.match(/^.*\/\/.*bitbucket.*\/.*$/)) {
      iconClass = 'fa-bitbucket';
    }

    return 'fa ' + iconClass;
  };
});

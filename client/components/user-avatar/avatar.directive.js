angular.module('probedock.userAvatar').directive('userAvatar', function() {
  return {
    restrict: 'E',
    templateUrl: '/templates/components/user-avatar/avatar.template.html',
    controller: 'UserAvatarCtrl',
    scope: {
      user: '=',
      size: '=',
      nameTooltip: '='
    }
  };
}).controller('UserAvatarCtrl', function($scope) {

  $scope.$watch('nameTooltip', function(value) {
    $scope.tooltipEnabled = !!value;
  });

  $scope.$watch('size', function(value) {
    if (value == 'large') {
      $scope.gravatarSize = 64;
    } else {
      $scope.gravatarSize = 30;
    }
  });
});

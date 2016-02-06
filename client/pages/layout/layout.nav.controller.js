angular.module('probedock.layout').controller('LayoutNavCtrl', function(api, appSettings, orgs, profile, $rootScope, $scope, $state) {

  appSettings.forwardSettings($scope);

  var state = $state.current;
  $rootScope.$on('$stateChangeSuccess', function(event, toState, toStateParams) {
    state = toState;
    $scope.orgName = toStateParams.orgName;
  });

  $scope.baseStateIs = function() {
    var names = Array.prototype.slice.call(arguments);
    return _.some(names, function(name) {
      return state && state.name && state.name.indexOf(name) === 0;
    });
  };

  profile.forwardData($scope);
  orgs.forwardData($scope);
});

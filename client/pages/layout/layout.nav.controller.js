angular.module('probedock.layout').controller('LayoutNavCtrl', function(api, appSettings, orgs, profile, $rootScope, $scope, $state, states) {

  appSettings.forwardSettings($scope);

  var state = $state.current;
  states.onState($scope, null, function(toState, toParams, toResolves) {
    state = toState;
    $scope.orgName = toParams.orgName || toResolves.routeOrgName;
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

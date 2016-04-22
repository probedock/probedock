angular.module('probedock.layout').controller('LayoutNavCtrl', function(api, appSettings, orgs, profile, $rootScope, $scope, states) {

  orgs.forwardData($scope);
  profile.forwardData($scope);
  appSettings.forwardSettings($scope);

  var currentStateName = null;
  states.onStateChangeSuccess($scope, true, function(state, params, resolves) {
    currentStateName = state.name;
  });

  $scope.baseStateIs = function() {
    var names = Array.prototype.slice.call(arguments);
    return currentStateName && _.some(names, function(name) {
      return currentStateName.indexOf(name) === 0;
    });
  };
});

angular.module('probedock.orgNameFilter', []).filter('orgName', function() {
  return function(input) {
    return input ? input.displayName || input.name : '';
  };
});

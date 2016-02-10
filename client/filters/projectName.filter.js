angular.module('probedock.projectNameFilter', []).filter('projectName', function() {
  return function(input) {
    return input ? input.displayName || input.name : '';
  };
});

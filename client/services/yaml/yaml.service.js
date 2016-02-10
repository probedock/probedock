angular.module('probedock.yaml').factory('yaml', function($window) {
  return {
    dump: function(object) {
      return jsyaml.safeDump(object);
    }
  };
});

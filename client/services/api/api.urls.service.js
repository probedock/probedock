angular.module('probedock.api').factory('urls', function($window) {
  return {
    join: function() {

      var url = arguments[0],
          parts = Array.prototype.slice.call(arguments, 1);

      _.each(parts, function(part) {
        url += '/' + part.replace(/^\//, '');
      });

      return url;
    },

    queryString: function(params) {
      return $window.jQuery.param(params);
    }
  };
});

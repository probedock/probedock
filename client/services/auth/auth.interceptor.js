angular.module('probedock.auth').factory('authInterceptor', function($q, $rootScope) {
  return {
    responseError: function(err) {

      if (err.status == 401) {
        $rootScope.$broadcast('auth.unauthorized', err);
      } if (err.status == 403) {
        $rootScope.$broadcast('auth.forbidden', err);
      } if (err.status == 404) {
        $rootScope.$broadcast('auth.notFound', err);
      }

      return $q.reject(err);
    }
  };
});

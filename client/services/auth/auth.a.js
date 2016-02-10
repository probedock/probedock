angular.module('probedock.auth', [ 'base64', 'probedock.storage' ])

  .config(function($httpProvider) {
    $httpProvider.interceptors.push('authInterceptor');
  })

  .run(function(auth, $rootScope) {
    $rootScope.currentUserIs = function() {

      var currentUser = $rootScope.currentUser,
          roles = Array.prototype.slice.call(arguments);

      return currentUser && _.isArray(currentUser.roles) && _.intersection(currentUser.roles, roles).length == roles.length;
    };
  })

  .run(function(auth, $rootScope, $state) {

    $rootScope.$on('auth.unauthorized', function(event, err) {
      auth.signOut();
      if (!err.config.custom || !err.config.custom.ignoreUnauthorized) {
        $state.go('error', { type: 'unauthorized' });
      }
    });

    // TODO: better authorization
    $rootScope.$on('auth.forbidden', function(event, err) {
      if (!err.config.custom || !err.config.custom.ignoreForbidden) {
        $state.go('error', { type: 'forbidden' });
      }
    });

    $rootScope.$on('auth.notFound', function(event, err) {
      if (!err.config.custom || !err.config.custom.ignoreNotFound) {
        $state.go('error', { type: 'notFound' });
      }
    });
  })

;

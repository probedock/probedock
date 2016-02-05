angular.module('probedock.auth', ['base64', 'probedock.storage'])

  .factory('auth', function(appStore, $base64, $http, $log, $modal, $rootScope) {

    var service = {

      signIn: function(credentials) {
        return $http({
          method: 'POST',
          url: '/api/authentication',
          headers: {
            Authorization: 'Basic ' + $base64.encode(credentials.username + ':' + credentials.password)
          },
          custom: {
            ignoreUnauthorized: true
          }
        }).then(onSignedIn);
      },

      signOut: function() {
        delete service.token;
        delete service.currentUser;
        $rootScope.currentUser = null;
        appStore.remove('auth.token');
        appStore.remove('auth.user');
        $rootScope.$broadcast('auth.signOut');
      },

      openSignInDialog: function() {
        $modal.open({
          templateUrl: '/templates/login-modal.html',
          controller: 'LoginCtrl'
        });
      },

      updateCurrentUser: function(user) {
        setUser(user);
        appStore.set('auth.user', user);
      }
    };

    var storedToken = appStore.get('auth.token'),
        storedUser = appStore.get('auth.user');

    if (storedToken && storedUser) {
      authenticate(storedToken, storedUser);
    }

    function onSignedIn(res) {
      authenticate(res.data.token, res.data.user);
      appStore.set('auth.token', res.data.token);
      appStore.set('auth.user', res.data.user);
      $rootScope.$broadcast('auth.signIn', res.data.user);
      return res.data.user;
    }

    function authenticate(token, user) {

      service.token = token;
      setUser(user);

      var roles = user.roles,
          rolesDescription = _.isArray(roles) && roles.length ? roles.join(', ') : 'none';

      $log.debug(user.primaryEmail + ' logged in (roles: ' + rolesDescription + ')');
    }

    function setUser(user) {
      service.currentUser = user;
      $rootScope.currentUser = user;
    }

    return service;
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

  .factory('authInterceptor', function($q, $rootScope) {
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
  })

  .config(function($httpProvider) {
    $httpProvider.interceptors.push('authInterceptor');
  })

  .controller('AuthCtrl', function(auth, $modal, $scope) {
    $scope.openSignInDialog = auth.openSignInDialog;
    $scope.signOut = auth.signOut;
  })

  .controller('LoginCtrl', function(auth, $http, $modalInstance, $scope, $location) {

    $scope.credentials = {};

    $scope.signIn = function() {
      delete $scope.error;
      auth.signIn($scope.credentials).then($scope.$close, showError);
    };

    $scope.getEmailUrl = function() {
      return ('mailto:support@probedock.io?' +
        // Build subject
        'subject=Please reset my password on ' + $location.host() +
        // Build body
        '&body=Dear Probe Dock Team,%0A%0A' +
        'Could you please reset my password on ' + $location.host() + '?' +
        (!_.isUndefined($scope.credentials.username) ? ' My user name is: ' + $scope.credentials.username : '') +
        '.%0A%0AThanks!').replace(' ', '%20');
    };

    $scope.$on('$stateChangeSuccess', function() {
      $modalInstance.dismiss('stateChange');
    });

    function showError() {
      $scope.error = true;
    }
  })

;

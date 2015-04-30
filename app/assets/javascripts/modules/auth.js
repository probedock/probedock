angular.module('probe-dock.auth', ['base64', 'probe-dock.storage'])

  .factory('auth', function(appStore, $base64, $http, $log, $modal, $rootScope) {

    $rootScope.currentUser = null;

    $rootScope.currentUserIs = function() {

      var currentUser = $rootScope.currentUser,
          roles = Array.prototype.slice.call(arguments);

      return currentUser && _.isArray(currentUser.roles) && _.intersection(currentUser.roles, roles).length == roles.length;
    };

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

  .run(function(auth, $rootScope, $state) {

    $rootScope.$on('auth.unauthorized', function(event, err) {
      auth.signOut();
      if (!err.config.custom || !err.config.custom.ignoreUnauthorized) {
        $state.go('error', { type: 'unauthorized' });
      }
    });

    // TODO: better authorization
    $rootScope.$on('auth.forbidden', function() {
      $state.go('error', { type: 'forbidden' });
    });
  })

  .factory('authInterceptor', function($q, $rootScope) {
    return {
      responseError: function(err) {

        if (err.status == 401) {
          $rootScope.$broadcast('auth.unauthorized', err);
        } if (err.status == 403) {
          $rootScope.$broadcast('auth.forbidden', err);
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

  .controller('LoginCtrl', function(auth, $http, $modalInstance, $scope) {

    $scope.credentials = {};

    $scope.signIn = function() {
      delete $scope.error;
      auth.signIn($scope.credentials).then($scope.$close, showError);
    };

    $scope.$on('$stateChangeSuccess', function() {
      $modalInstance.dismiss('stateChange');
    });

    function showError() {
      $scope.error = true;
    }
  })

;

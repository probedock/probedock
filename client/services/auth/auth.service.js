angular.module('probedock.auth').factory('auth', function(appStore, $base64, $http, $log, $modal, $rootScope) {

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
        templateUrl: '/templates/services/auth/auth.login.modal.template.html',
        controller: 'LoginModalCtrl'
      });
    },

    updateCurrentUser: function(user) {
      setUser(user);
      appStore.set('auth.user', user);
    },

    addAuthFunctions: function($scope) {
      $scope.currentUserIs = function() {
        var currentUser = $rootScope.currentUser,
            roles = Array.prototype.slice.call(arguments);

        return currentUser && _.isArray(currentUser.roles) && _.intersection(currentUser.roles, roles).length == roles.length;
      };
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
});

angular.module('probe-dock.auth', ['base64', 'probe-dock.storage'])

  .factory('auth', function(appStore, $base64, $http, $log, $modal, $rootScope) {

    // TODO: move this to run block with forwardData function
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
          }
        }).then(onSignedIn);
      },

      signOut: function() {
        delete service.token;
        delete service.currentUser;
        $rootScope.currentUser = null;
        appStore.remove('auth');
        $rootScope.$broadcast('auth.signOut');
      },

      openSignInDialog: function() {
        $modal.open({
          templateUrl: '/templates/login-modal.html',
          controller: 'LoginCtrl'
        });
      }
    };

    var authData = appStore.get('auth');
    if (authData) {
      authenticate(authData);
    }

    function onSignedIn(response) {
      authenticate(response.data);
      appStore.set('auth', response.data);
      $rootScope.$broadcast('auth.signIn', response.data.user);
    }

    function authenticate(authData) {
      service.token = authData.token;
      service.currentUser = authData.user;
      $rootScope.currentUser = authData.user;

      var roles = authData.user.roles,
          rolesDescription = _.isArray(roles) && roles.length ? roles.join(', ') : 'none';

      $log.debug(authData.user.primaryEmail + ' logged in (roles: ' + rolesDescription + ')');
    }

    return service;
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

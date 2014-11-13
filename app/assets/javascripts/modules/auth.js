angular.module('rox.auth', ['LocalStorageModule', 'ui.bootstrap'])

  .factory('AuthService', ['$http', 'localStorageService', '$rootScope', function($http, $local, $rootScope) {

    $rootScope.currentUser = null;

    var service = {

      signIn: function(credentials) {
        return $http({
          method: 'POST',
          url: '/api/authenticate',
          data: _.pick(credentials, 'username', 'password')
        }).then(onSignedIn);
      },

      signOut: function() {
        delete service.token;
        $rootScope.currentUser = null;
        $local.remove('auth');
      },

      checkSignedIn: function() {

        var authData = $local.get('auth');
        if (authData) {
          authenticate(authData);
        }
      }
    };

    function onSignedIn(response) {
      authenticate(response.data);
      $local.set('auth', response.data);
    }

    function authenticate(authData) {
      service.token = authData.token;
      $rootScope.currentUser = authData.user;
    }

    return service;
  }])

  .controller('AuthCtrl', ['AuthService', '$modal', '$scope', function($auth, $modal, $scope) {

    $scope.showSignIn = function() {
      $modal.open({
        templateUrl: '/templates/loginDialog.html',
        controller: 'LoginCtrl'
      });
    };

    $scope.signOut = $auth.signOut;
  }])

  .controller('LoginCtrl', ['AuthService', '$http', '$scope', function($auth, $http, $scope) {

    $scope.credentials = {};

    $scope.signIn = function() {
      delete $scope.error;
      $auth.signIn($scope.credentials).then($scope.$close, showError);
    };

    function showError() {
      $scope.error = true;
    }
  }])

;

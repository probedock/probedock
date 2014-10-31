angular.module('rox.auth', ['base64', 'LocalStorageModule', 'ui.bootstrap'])

  .factory('AuthService', ['$base64', '$http', 'localStorageService', '$rootScope', function($base64, $http, $local, $rootScope) {

    $rootScope.currentUser = null;

    return {

      logout: function() {
        $rootScope.currentUser = null;
      },

      authenticate: function(username, password) {
        return $http({
          method: 'POST',
          url: '/api/authenticate',
          data: {
            username: username,
            password: password
          }
        }).then(function(response) {

          var token = response.data.token,
              parts = token.split(/\./),
              claimsBase64 = parts[1];

          var padding = claimsBase64.length % 4;
          if (padding) {
            claimsBase64 += Array(padding + 1).join('=');
          }

          var claims = JSON.parse($base64.decode(claimsBase64));

          $rootScope.currentUser = {
            email: claims.iss
          };
        });
      }
    };
  }])

  .controller('AuthController', ['AuthService', '$modal', '$scope', function($auth, $modal, $scope) {

    $scope.showSignIn = function() {
      var modal = $modal.open({
        templateUrl: '/templates/loginDialog.html',
        controller: 'LoginController'
      });
    };

    $scope.signOut = function() {
      $auth.logout();
    };
  }])

  .controller('LoginController', ['AuthService', '$http', '$scope', function($auth, $http, $scope) {

    $scope.signIn = function() {
      $auth.authenticate($scope.username, $scope.password).then($scope.$close);
    };
  }])

;

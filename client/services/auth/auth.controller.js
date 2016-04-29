angular.module('probedock.auth').controller('AuthCtrl', function(auth, $scope) {
  $scope.openSignInDialog = auth.openSignInDialog;
  $scope.signOut = auth.signOut;
});

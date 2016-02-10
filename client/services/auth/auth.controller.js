angular.module('probedock.auth').controller('AuthCtrl', function(auth, $modal, $scope) {
  $scope.openSignInDialog = auth.openSignInDialog;
  $scope.signOut = auth.signOut;
});

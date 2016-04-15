angular.module('probedock.managementPage').controller('ManagementPageCtrl', function(api, $scope, orgs) {
  orgs.forwardData($scope);
});

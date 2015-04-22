angular.module('probe-dock.home', [ 'probe-dock.orgs' ])

  .controller('HomeCtrl', function(orgs, $scope) {

    orgs.forwardData($scope);

    $scope.addOrganization = function() {
      var modal = orgs.openForm($scope);

      modal.result.then(function(org) {
        $scope.createdOrg = org;
      });
    };
  })

;

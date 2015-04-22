angular.module('probe-dock.home', [ 'probe-dock.api', 'probe-dock.orgs' ])

  .controller('HomeCtrl', function(api, orgs, $scope) {

    orgs.forwardData($scope);

    $scope.addOrganization = function() {
      var modal = orgs.openForm($scope);

      modal.result.then(function(org) {
        $scope.createdOrg = org;
      });
    };
  })

;

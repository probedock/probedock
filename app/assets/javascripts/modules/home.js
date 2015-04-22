angular.module('probe-dock.home', [ 'probe-dock.api', 'probe-dock.orgs' ])

  .controller('HomeCtrl', function(api, orgs, $scope) {

    // TODO: extract this in org service
    refreshOrgs();
    $scope.$on('auth.signIn', refreshOrgs);
    $scope.$on('auth.signOut', hidePrivateOrgs);

    function hidePrivateOrgs() {
      $scope.organizations = _.where($scope.organizations, { public: true });
    }

    function refreshOrgs() {
      api.http({
        url: '/api/organizations'
      }).then(function(res) {
        $scope.organizations = res.data;
      });
    }

    $scope.addOrganization = function() {
      orgs.openForm($scope);
    };
  })

;

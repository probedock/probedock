angular.module('probe-dock.orgs.members', [ 'probe-dock.api' ])

  .controller('OrgMembersCtrl', function(api, $scope, $stateParams) {

    api({
      url: '/api/organizations/' + $stateParams.orgName + '/memberships',
      params: {
        withUser: 1
      }
    }).then(function(res) {
      $scope.memberships = res.data;
    });
  })

;

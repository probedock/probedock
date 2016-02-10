angular.module('probedock.profilePage').controller('ProfileMembershipsCtrl', function(api, auth, profile, $scope) {

  $scope.memberships = [];

  api({
    url: '/memberships',
    params: {
      mine: 1,
      accepted: 1,
      withOrganization: 1
    }
  }).then(function(res) {
    $scope.memberships = res.data;
  });

  profile.forwardData($scope);

  $scope.accept = function(membership) {
    api({
      method: 'PATCH',
      url: '/memberships/' + membership.id,
      data: {
        userId: auth.currentUser.id
      }
    }).then(function(res) {
      profile.updateMembership(res.data);
      $scope.memberships.push(_.defaults(res.data, membership));
    });
  };
});

angular.module('probedock.profile').factory('profile', function(api, auth, eventUtils, $rootScope) {

  var service = eventUtils.service({

    pendingMemberships: [],

    forwardData: function($scope) {

      setPendingMemberships();

      service.forward($scope, 'refresh.pendingMemberships', { prefix: 'profile.' });
      $scope.$on('profile.refresh.pendingMemberships', setPendingMemberships);

      function setPendingMemberships() {
        $scope.pendingMemberships = service.pendingMemberships;
      }
    },

    updateMembership: function(membership) {

      var pendingMembership = _.findWhere(service.pendingMemberships, { id: membership.id });
      if (pendingMembership) {
        service.pendingMemberships.splice(service.pendingMemberships.indexOf(pendingMembership), 1);
        service.emit('refresh.pendingMemberships', service.pendingMemberships);
      }
    }
  });

  if (auth.currentUser) {
    refreshPendingMemberships();
  }

  $rootScope.$on('auth.signIn', refreshPendingMemberships);
  $rootScope.$on('auth.signOut', removePendingMemberships);

  function refreshPendingMemberships() {
    api({
      url: '/memberships',
      params: {
        mine: 1,
        accepted: 0,
        withOrganization: 1
      },
      custom: {
        ignoreUnauthorized: true
      }
    }).then(function(res) {
      setPendingMemberships(res.data);
    });
  }

  function removePendingMemberships() {
    setPendingMemberships([]);
  }

  function setPendingMemberships(memberships) {
    service.pendingMemberships = memberships;
    service.emit('refresh.pendingMemberships', memberships);
  }

  return service;
});

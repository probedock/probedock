angular.module('probe-dock.profile', [ 'probe-dock.api', 'probe-dock.auth', 'probe-dock.utils' ])

  .factory('profile', function(api, auth, eventUtils, $rootScope) {

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
        url: '/api/memberships',
        params: {
          mine: 1,
          accepted: 0,
          withOrganization: 1
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
  })

  .controller('ProfileAccessTokensCtrl', function(api, $scope) {

    $scope.busy = false;

    $scope.generate = function() {

      $scope.busy = true;
      delete $scope.token;

      api({
        method: 'POST',
        url: '/api/tokens'
      }).then(showToken, onGenerateError);
    };

    function onGenerateError() {
      delete $scope.token;
      $scope.generateError = true;
      $scope.busy = false;
    }

    function showToken(response) {
      $scope.token = response.data.token;
      $scope.busy = false;
    }
  })

  .controller('ProfileDetailsCtrl', function(api, auth, $scope) {

    var modal;
    $scope.edit = function() {
      delete $scope.saveError;
      $scope.editedProfile = _.pick(auth.currentUser, 'name', 'email');
    };

    $scope.cancel = function() {
      delete $scope.editedProfile;
    };

    $scope.save = function() {
      api({
        method: 'PATCH',
        url: '/api/users/' + auth.currentUser.id,
        data: api.compact($scope.editedProfile)
      }).then(onSaved, onSaveError);
    };

    function onSaveError() {
      $scope.saveError = true;
    }

    function onSaved(response) {
      delete $scope.editedProfile;
      _.extend(auth.currentUser, response.data);
    }
  })

  .controller('ProfileMembershipsCtrl', function(api, auth, profile, $scope) {

    $scope.memberships = [];

    api({
      url: '/api/memberships',
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
        url: '/api/memberships/' + membership.id,
        data: {
          userId: auth.currentUser.id
        }
      }).then(function(res) {
        profile.updateMembership(res.data);
        $scope.memberships.push(_.defaults(res.data, membership));
      });
    };
  })

;

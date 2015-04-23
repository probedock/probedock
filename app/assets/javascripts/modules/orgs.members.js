angular.module('probe-dock.orgs.members', [ 'probe-dock.api' ])

  .factory('orgMembers', function(api, $modal) {

    var service = {
      openForm: function($scope) {

        var modal = $modal.open({
          templateUrl: '/templates/org-member-modal.html',
          controller: 'OrgMemberModalCtrl',
          scope: $scope
        });

        var deregister = $scope.$on('$stateChangeStart', function() {
          modal.dismiss('stateChange');
          deregister();
        });

        $scope.$on('$destroy', deregister);

        return modal;
      }
    };

    return service;
  })

  .controller('OrgMembersCtrl', function(api, orgMembers, $scope, $state, $stateParams) {

    api({
      url: '/api/memberships',
      params: {
        organizationName: $stateParams.orgName,
        withUser: 1
      }
    }).then(function(res) {
      $scope.memberships = res.data;
    });

    $scope.$on('$stateChangeSuccess', function(event, toState) {
      if (toState.name.match(/^org\.dashboard\.members\.(?:new|edit)$/)) {

        var modal = orgMembers.openForm($scope);

        modal.result.then(function() {
          $state.go('^', {}, { inherit: true });
        }, function(reason) {
          if (reason != 'stateChange') {
            $state.go('^', {}, { inherit: true });
          }
        });
      }
    });
  })

  .controller('OrgMemberModalCtrl', function(api, forms, $modalInstance, $scope, $stateParams) {

    $scope.membership = {};
    $scope.editedMembership = {};

    if ($stateParams.id) {
      api({
        url: '/api/memberships/' + $stateParams.id,
        params: {
          withUser: 1
        }
      }).then(function(res) {
        $scope.membership = res.data;
        reset();
      });
    }

    $scope.reset = reset;
    $scope.changed = function() {
      return !forms.dataEquals($scope.membership, $scope.editedMembership);
    };

    $scope.save = function() {

      var method = 'POST',
          url = '/api/memberships';

      if ($scope.membership.id) {
        method = 'PATCH';
        url += '/' + $scope.membership.id;
      }

      api({
        method: method,
        url: url,
        data: $scope.editedMembership
      }).then(function(res) {
        $modalInstance.close(res.data);
      });
    };

    function reset() {
      $scope.editedMembership = angular.copy($scope.membership);
    }
  })

;

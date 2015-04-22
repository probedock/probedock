angular.module('probe-dock.orgs', [ 'probe-dock.api' ])

  .factory('orgs', function($modal) {

    var service = {
      openForm: function($scope) {

        var modal = $modal.open({
          templateUrl: '/templates/org-form-modal.html',
          controller: 'OrgFormCtrl',
          scope: $scope
        });

        return modal;
      }
    };

    return service;
  })

  .controller('OrgFormCtrl', function(api, $modalInstance, $scope, $stateParams) {

    $scope.organization = {};

    if ($stateParams.orgName) {
      api.http({
        url: '/api/organizations/' + $stateParams.orgName
      }).then(function(res) {
        $scope.organization = res.data;
        reset();
      });
    } else {
      reset();
    }

    $scope.reset = reset;

    $scope.save = function() {

      var method = 'POST',
          url = '/api/organizations';

      if ($scope.organization.id) {
        method = 'PATCH';
        url += '/' + $scope.organization.id;
      }

      api.http({
        method: method,
        url: url,
        data: $scope.editedOrg
      }).then(function(res) {
        $modalInstance.close(res.data);
      });
    };

    function reset() {
      $scope.editedOrg = angular.copy($scope.organization);
    }
  })

;

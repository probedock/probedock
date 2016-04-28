angular.module('probedock.orgEditModal').factory('orgEditModal', function(states, $uibModal) {
  return {
    open: function($scope, options) {
      options = _.extend({}, options);

      var scope = $scope.$new();
      _.extend(scope, _.pick(options, 'organization', 'organizationId', 'organizationName'));

      var modal = $uibModal.open({
        templateUrl: '/templates/pages/org-edit-modal/modal.template.html',
        controller: 'OrgEditModalCtrl',
        scope: scope
      });

      states.onStateChangeStart($scope, true, function() {
        modal.dismiss('stateChange');
      });

      return modal;
    }
  };
}).controller('OrgEditModalCtrl', function(api, forms, orgs, $scope, $uibModalInstance) {

  $scope.organization = $scope.organization || {};
  $scope.editedOrg = {};

  if ($scope.organization && $scope.organization.id) {
    // Edit the specified organization.
    resetEditedOrganization();
  } else if ($scope.organizationId) {
    api({
      url: '/organizations/' + $scope.organizationId
    }).then(function(res) {
      $scope.organization = res.data;
      resetEditedOrganization();
    });
  } else if ($scope.organizationName) {
    api({
      url: '/organizations',
      params: {
        name: $scope.organizationName
      }
    }).then(function(res) {
      // TODO: handle not found
      $scope.organization = res.data.length ? res.data[0] : null;
      resetEditedOrganization();
    });
  } else {
    resetEditedOrganization();
  }

  $scope.reset = resetEditedOrganization;
  $scope.changed = function() {
    return !forms.dataEquals($scope.organization, $scope.editedOrg);
  };

  $scope.save = function() {

    var method = 'POST',
        url = '/organizations';

    if ($scope.organization.id) {
      method = 'PATCH';
      url += '/' + $scope.organization.id;
    }

    api({
      method: method,
      url: url,
      data: $scope.editedOrg
    }).then(function(res) {
      orgs[$scope.organization.id ? 'updateOrganization' : 'addOrganization'](res.data);
      $uibModalInstance.close(res.data);
    });
  };

  function resetEditedOrganization() {
    $scope.editedOrg = angular.copy($scope.organization);
  }
});

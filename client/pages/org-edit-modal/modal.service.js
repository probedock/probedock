angular.module('probedock.orgEditModal').factory('orgEditModal', function($modal) {
  return {
    open: function($scope) {

      var modal = $modal.open({
        templateUrl: '/templates/pages/org-edit-modal/modal.template.html',
        controller: 'OrgEditModalCtrl',
        scope: $scope
      });

      $scope.$on('$stateChangeStart', function() {
        modal.dismiss('stateChange');
      });

      return modal;
    }
  };
}).controller('OrgEditModalCtrl', function(api, forms, $modalInstance, orgs, $scope, $stateParams) {

  $scope.organization = {};
  $scope.editedOrg = {};

  if ($stateParams.orgName) {
    api({
      url: '/organizations',
      params: {
        name: $stateParams.orgName
      }
    }).then(function(res) {
      // TODO: handle not found
      $scope.organization = res.data.length ? res.data[0] : null;
      reset();
    });
  }

  $scope.reset = reset;
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

    $scope.editedOrg.name = api.slugify($scope.editedOrg.displayName);

    api({
      method: method,
      url: url,
      data: $scope.editedOrg
    }).then(function(res) {
      orgs[$scope.organization.id ? 'updateOrganization' : 'addOrganization'](res.data);
      $modalInstance.close(res.data);
    });
  };

  function reset() {
    $scope.editedOrg = angular.copy($scope.organization);
  }
});

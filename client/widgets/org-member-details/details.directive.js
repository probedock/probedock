angular.module('probedock.orgMemberDetailsWidget').directive('orgMemberDetailsWidget', function() {
  return {
    restrict: 'E',
    controller: 'OrgMemberDetailsWidgetCtrl',
    templateUrl: '/templates/widgets/org-member-details/details.template.html',
    scope: {
      membership: '=',
      onDelete: '&'
    }
  };
}).controller('OrgMemberDetailsWidgetCtrl', function(api, orgs, $scope) {
  orgs.addAuthFunctions($scope);

  $scope.generateAccessToken = generateAccessToken;
  $scope.remove = deleteMembership;

  function generateAccessToken() {
    api({
      method: 'POST',
      url: '/tokens',
      data: {
        userId: $scope.membership.user.id
      }
    }).then(function(res) {
      $scope.accessToken = res.data.token;
    });
  }

  function deleteMembership() {

    var membership = $scope.membership;

    var message;
    if (membership.user && membership.user.technical) {
      message = "Are you sure you want to delete technical user " + membership.user.name + '?';
    } else {
      message = "Are you sure you want to remove ";
      message += membership.user ? membership.user.name : membership.organizationEmail;
      message += "'s membership?";
    }

    if (!confirm(message)) {
      return;
    }

    var promise;
    if (membership.user && membership.user.technical) {
      promise = deleteTechnicalUser();
    } else {
      promise = deleteMembership();
    }

    promise.then(function() {
      $scope.onDelete();
    });

    function deleteMembership() {
      return api({
        method: 'DELETE',
        url: '/memberships/' + membership.id
      });
    }

    function deleteTechnicalUser() {
      return api({
        method: 'DELETE',
        url: '/users/' + membership.user.id
      });
    }
  };
});

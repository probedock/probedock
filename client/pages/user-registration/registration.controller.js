angular.module('probedock.userRegistrationPage').controller('UserRegistrationPageCtrl', function(api, $scope) {

  $scope.user = {};
  $scope.organization = {};

  $scope.register = function() {

    var data = {
      user: $scope.user,
      organization: $scope.organization
    };

    data.organization.name = api.slugify(data.organization.displayName);

    api({
      method: 'POST',
      url: '/registrations',
      data: data
    }).then(function(res) {
      $scope.registration = res.data;
    });
  };
});

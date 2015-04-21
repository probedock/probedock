angular.module('probe-dock.home', ['probe-dock.api'])

  .controller('HomeCtrl', function(api, $scope) {
    api.http({
      url: '/api/organizations'
    }).then(function(res) {
      $scope.organizations = res.data;
    });
  })

;

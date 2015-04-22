angular.module('probe-dock.nav', [])

  .directive('spinner', function() {
    return {
      restrict: 'E',
      template: '<div class="spinner"><div class="bounce1"></div><div class="bounce2"></div><div class="bounce3"></div></div>'
    };
  })

  .controller('NavCtrl', function(api, $rootScope, $scope, $state) {

    var state = $state.current;
    $rootScope.$on('$stateChangeSuccess', function(event, toState, toStateParams) {
      state = toState;
      $scope.orgName = toStateParams.orgName;
    });

    $scope.baseStateIs = function() {
      var names = Array.prototype.slice.call(arguments);
      return _.some(names, function(name) {
        return state && state.name && state.name.indexOf(name) === 0;
      });
    };

    // TODO: extract this in org service
    refreshOrgs();
    $scope.$on('auth.signIn', refreshOrgs);
    $scope.$on('auth.signOut', hidePrivateOrgs);

    function hidePrivateOrgs() {
      $scope.organizations = _.where($scope.organizations, { public: true });
    }

    function refreshOrgs() {
      api.http({
        url: '/api/organizations'
      }).then(function(res) {
        $scope.organizations = res.data;
      });
    }
  })

;

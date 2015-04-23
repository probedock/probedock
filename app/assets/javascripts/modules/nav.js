angular.module('probe-dock.nav', [ 'probe-dock.orgs', 'probe-dock.profile' ])

  .directive('spinner', function() {
    return {
      restrict: 'E',
      template: '<div class="spinner"><div class="bounce1"></div><div class="bounce2"></div><div class="bounce3"></div></div>'
    };
  })

  .controller('NavCtrl', function(api, orgs, profile, $rootScope, $scope, $state) {

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

    profile.forwardData($scope);
    orgs.forwardData($scope);
  })

;

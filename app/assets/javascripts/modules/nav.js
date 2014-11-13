angular.module('rox.nav', [])

  .controller('NavCtrl', [ '$rootScope', '$scope', '$state', function($rootScope, $scope, $state) {

    var state = $state.current;
    $rootScope.$on('$stateChangeSuccess', function(event, toState) {
      state = toState;
    });

    $scope.isMenuActive = function(stateName) {
      return state && state.name && state.name.indexOf('std.' + stateName) === 0;
    };
  }])

;

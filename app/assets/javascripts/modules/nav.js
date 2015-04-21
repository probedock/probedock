angular.module('probe-dock.nav', [])

  .directive('spinner', [function() {
    return {
      restrict: 'E',
      template: '<div class="spinner"><div class="bounce1"></div><div class="bounce2"></div><div class="bounce3"></div></div>'
    };
  }])

  .controller('NavCtrl', [ '$rootScope', '$scope', '$state', function($rootScope, $scope, $state) {

    var state = $state.current;
    $rootScope.$on('$stateChangeSuccess', function(event, toState, toStateParams) {
      state = toState;
      $scope.orgName = toStateParams.orgName;
    });

    $scope.isMenuActive = function(stateName) {
      return state && state.name && state.name.indexOf('org.' + stateName) === 0;
    };
  }])

;

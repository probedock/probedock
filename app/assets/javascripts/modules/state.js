angular.module('rox.state', [ 'ui.router' ])

  .config(['$locationProvider', '$urlRouterProvider', function($locationProvider, $urlRouterProvider) {
    $locationProvider.html5Mode(true);
    $urlRouterProvider.otherwise("/");
  }])

  .factory('StateService', ['$rootScope', '$state', '$stateParams', '$timeout', function($rootScope, $state, $stateParams, $timeout) {

    var onStateCallbacks = [];

    $rootScope.$on('$stateChangeSuccess', checkState);

    function checkState(event, toState, toParams, fromState, fromParams) {

      _.each(onStateCallbacks, function(onStateCallback) {

        if (_.isString(onStateCallback.options.name) && toState.name !== onStateCallback.options.name) {
          return;
        } else if (_.isArray(onStateCallback.options.name) && !_.contains(onStateCallback.options.name, toState.name)) {
          return;
        }

        if (onStateCallback.options.params && _.some(onStateCallback.options.params, function(value, name) {
          return toParams[name] !== value;
        })) {
          return;
        }

        onStateCallback.callback(toState, toParams, fromState, fromParams);
      });
    }

    return {
      onState: function(stateOptions, scope, callback) {

        var callback = { options: stateOptions, callback: callback };
        onStateCallbacks.push(callback);

        $timeout(function() {
          checkState(undefined, $state.current, $stateParams);
        });

        scope.$on('$destroy', function() {
          onStateCallbacks.splice(onStateCallbacks.indexOf(callback), 1);
        });
      }
    };
  }])

;

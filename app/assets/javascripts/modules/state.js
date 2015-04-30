angular.module('probe-dock.state', [ 'ui.router' ])

  .config(function($locationProvider, $urlRouterProvider) {
    $locationProvider.html5Mode(true);
  })

  .factory('states', function($rootScope, $state, $stateParams, $timeout) {

    var onStateCallbacks = [];

    $rootScope.$on('$stateChangeSuccess', checkState);

    function checkState(event, toState, toParams, fromState, fromParams) {

      _.each(onStateCallbacks, function(callback) {

        var matcher = callback.matcher,
            options = callback.options,
            func = callback.func;

        if (_.isRegExp(matcher) && !toState.name.match(matcher)) {
          return;
        } else if (_.isString(matcher) && toState.name !== matcher) {
          return;
        } else if (_.isArray(matcher) && !_.contains(matcher, toState.name)) {
          return;
        }

        if (options.params && _.some(options.params, function(value, name) {
          return toParams[name] !== value;
        })) {
          return;
        }

        callback.func(toState, toParams, fromState, fromParams);
      });
    }

    return {
      onState: function($scope, matcher, options, func) {

        var callback = {
          matcher: matcher
        };

        if (typeof(options) == 'function') {
          callback.options = {};
          callback.func = options;
        } else {
          callback.options = options || {};
          callback.func = callback;
        }

        onStateCallbacks.push(callback);

        $timeout(function() {
          checkState(undefined, $state.current, $stateParams);
        });

        $scope.$on('$destroy', function() {
          onStateCallbacks.splice(onStateCallbacks.indexOf(callback), 1);
        });
      }
    };
  })

;

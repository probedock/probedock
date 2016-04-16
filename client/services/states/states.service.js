angular.module('probedock.states').factory('states', function($rootScope, $state, $stateParams, $timeout, $transitions) {

  var currentStateName = $state.$current ? $state.$current.name : null,
      currentStateParams = $state.$current ? $state.$current.params : {},
      onStateCallbacks = [],
      onStateChangeCallbacks = [];

  $transitions.onStart({}, [ '$transition$', function(transition) {
    checkStateChange(transition.to(), transition.params(), transition.resolves());
  } ]);

  $transitions.onSuccess({}, [ '$transition$', function(transition) {
    checkState(transition.to(), transition.params(), transition.resolves(), onStateCallbacks);
  } ]);

  function buildCallback(matcher, options, func) {
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

    return callback;
  }

  function stateMatches(state, matcher, options) {
    if (!matcher) {
      return true;
    } else if (_.isRegExp(matcher) && !state.name.match(matcher)) {
      return false;
    } else if (_.isString(matcher) && state.name !== matcher) {
      return false;
    } else if (_.isArray(matcher) && !_.contains(matcher, state.name)) {
      return false;
    }

    if (options.params && _.some(options.params, function(value, name) {
      return toParams[name] !== value;
    })) {
      return false;
    }

    return true;
  }

  function checkState(toState, toParams, toResolve, callbacks) {

    currentStateName = toState.name;
    currentStateParams = toParams || {};

    _.each(onStateCallbacks, function(callback) {
      if (stateMatches(toState, callback.matcher, callback.options)) {
        callback.func(toState, toParams || {}, toResolve || {});
      }
    });
  }

  function checkStateChange(toState, toParams, toResolve) {
    _.each(onStateChangeCallbacks, function(callback) {
      if (stateMatches(toState, callback.matcher, callback.options)) {
        callback.func(toState, toParams || {}, toResolve || {});
      }
    });
  }

  return {
    onStateChange: function($scope, matcher, options, func) {

      var callback = buildCallback(matcher, options, func);
      onStateChangeCallbacks.push(callback);

      if ($scope != $rootScope) {
        $scope.$on('$destroy', function() {
          onStateChangeCallbacks.splice(onStateChangeCallbacks.indexOf(callback), 1);
        });
      }
    },

    onState: function($scope, matcher, options, func) {

      var callback = buildCallback(matcher, options, func);
      onStateCallbacks.push(callback);

      if ($state.$current) {
        checkState($state.$current, $state.params || {}, $state.$current.resolve || {}, [ callback ]);
      }

      if ($scope != $rootScope) {
        $scope.$on('$destroy', function() {
          onStateCallbacks.splice(onStateCallbacks.indexOf(callback), 1);
        });
      }
    }
  };
});

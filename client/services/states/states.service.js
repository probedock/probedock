/**
 * Service that abstracts the management of UI Router state transitions.
 *
 * Documentation: http://angular-ui.github.io/ui-router/feature-1.0/index.html
 */
angular.module('probedock.states').factory('states', function($rootScope, $transitions) {

  var currentState = null,
      onStateChangeStartCallbacks = [],
      onStateChangeSuccessCallbacks = [];

  var service = {

    /**
     * Registers a callback function that will be called when a state transition is started that
     * matches the specified criteria.
     *
     * The current $scope must be given as the first argument. The callback function will automatically
     * be unregistered when that scope is destroyed. If you need a permanent callback function to be
     * registered, for example in a service, pass the $rootScope.
     *
     * The matcher can be one of the following:
     *
     * * String: only a transition to a state with a name that is an exact match will trigger the callback.
     * * RegExp: only a transition to a state with a name that matches the regular expression will trigger the callback.
     * * Array: only a transition to a state with a name included in the array will trigger the callback.
     * * true: any transition will trigger the callback.
     * * false: no transition will trigger the callback.
     *
     * The options argument is reserved for future use. It may be omitted.
     *
     *     states.onStateChangeStart($scope, 'org.projects.list', function(state, params, resolves) { ... });
     *     states.onStateChangeStart($scope, /^admin\.users\./, function(state, params, resolves) { ... });
     *     states.onStateChangeStart($scope, [ 'org.reports', 'org.reports.show' ], function(state, params, resolves) { ... });
     *     states.onStateChangeStart($scope, true, function(state, params, resolves) { ... });
     *
     * The callback function will be called with the state object, the state params, and the resolved state params:
     *
     *     states.onStateChangeStart($scope, true, function(state, params, resolves) {
     *       console.log(state.name);
     *       console.log(params.id);
     *       console.log(resolves.customData);
     *     });
     */
    onStateChangeStart: function($scope, matcher, options, func) {

      var stateCallback = buildStateCallback(matcher, options, func);
      onStateChangeStartCallbacks.push(stateCallback);

      $scope.$on('$destroy', function() {
        onStateChangeStartCallbacks.splice(onStateChangeStartCallbacks.indexOf(stateCallback), 1);
      });
    },

    /**
     * Registers a callback function that will be called when a state transition finishes that
     * matches the specified criteria. If the current state matches the criteria when the callback
     * function is registered, it is called immediately.
     *
     * The current $scope must be given as the first argument. The callback function will automatically
     * be unregistered when that scope is destroyed.
     *
     * The matcher can be one of the following:
     *
     * * String: only a transition to a state with a name that is an exact match will trigger the callback.
     * * RegExp: only a transition to a state with a name that matches the regular expression will trigger the callback.
     * * Array: only a transition to a state with a name included in the array will trigger the callback.
     * * true: any transition will trigger the callback.
     * * false: no transition will trigger the callback.
     *
     * The options argument is reserved for future use. It may be omitted.
     *
     *     states.onStateChangeStart($scope, 'org.projects.list', function(state, params, resolves) { ... });
     *     states.onStateChangeStart($scope, /^admin\.users\./, function(state, params, resolves) { ... });
     *     states.onStateChangeStart($scope, [ 'org.reports', 'org.reports.show' ], function(state, params, resolves) { ... });
     *     states.onStateChangeStart($scope, true, function(state, params, resolves) { ... });
     *
     * The callback function will be called with the state object, the state params, and the resolved state params:
     *
     *     states.onStateChangeStart($scope, true, function(state, params, resolves) {
     *       console.log(state.name);
     *       console.log(params.id);
     *       console.log(resolves.customData);
     *     });
     */
    onStateChangeSuccess: function($scope, matcher, options, func) {

      var stateCallback = buildStateCallback(matcher, options, func);
      onStateChangeSuccessCallbacks.push(stateCallback);

      if (currentState) {
        triggerStateCallbacks(currentState, [ stateCallback ]);
      }

      $scope.$on('$destroy', function() {
        onStateChangeSuccessCallbacks.splice(onStateChangeSuccessCallbacks.indexOf(stateCallback), 1);
      });
    }
  };

  // Called when state transitions start.
  $transitions.onStart({}, [ '$transition$', function(transition) {
    triggerStateCallbacks(stateFromTransition(transition), onStateChangeStartCallbacks);
  } ]);

  // Called when state transitions succeed.
  $transitions.onSuccess({}, [ '$transition$', function(transition) {

    var state = stateFromTransition(transition);

    // Keep track of current state.
    currentState = state;

    triggerStateCallbacks(state, onStateChangeSuccessCallbacks);
  } ]);

  function buildStateCallback(matcher, options, func) {
    if (matcher !== true && matcher !== false && !_.isString(matcher) && !_.isRegExp(matcher) && !_.isArray(matcher)) {
      throw new Error('Unsupported matcher type; must be one of true, false, string, regexp, array; got ' + matcher + ' (' + typeof(matcher) + ')');
    }

    var callback = {
      matcher: matcher
    };

    if (typeof(options) == 'function') {
      // No options were given, use `options` as the callback function.
      callback.options = {};
      callback.func = options;
    } else if (typeof(func) != 'function') {
      throw new Error('A callback function must be given as the third or fourth argument to #onStateChangeStart or #onStateChangeSuccess');
    } else {
      // Options were given.
      callback.options = options || {};
      callback.func = func;
    }

    return callback;
  }

  function stateFromTransition(transition) {
    return {
      name: transition.to().name,
      params: transition.params() || {},
      resolves: transition.resolves() || {}
    };
  }

  function triggerStateCallbacks(state, stateCallbacks) {
    _.each(stateCallbacks, function(stateCallback) {
      if (stateMatches(state, stateCallback)) {
        callStateCallback(state, stateCallback);
      }
    });
  }

  function stateMatches(state, stateCallback) {

    var matcher = stateCallback.matcher;

    if (matcher === true) {
      return true;
    } else if (matcher === false) {
      return false;
    } else if (_.isRegExp(matcher) && !state.name.match(matcher)) {
      return false;
    } else if (_.isString(matcher) && state.name !== matcher) {
      return false;
    } else if (_.isArray(matcher) && !_.contains(matcher, state.name)) {
      return false;
    }

    return true;
  }

  function callStateCallback(state, stateCallback) {
    stateCallback.func(state, state.params, state.resolves);
  }

  return service;
}).run(function(states) {
  // This run function is here only to ensure that the state service is instantiated
  // as soon as possible, before transitions events start being triggered.
  states.active = true;
});

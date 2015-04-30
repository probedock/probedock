angular.module('probe-dock.utils', [])

  .factory('urls', function($window) {
    return {
      join: function() {

        var url = arguments[0],
            parts = Array.prototype.slice.call(arguments, 1);

        _.each(parts, function(part) {
          url += '/' + part.replace(/^\//, '');
        });

        return url;
      },

      queryString: function(params) {
        return $window.jQuery.param(params);
      }
    };
  })

  .factory('eventUtils', function($timeout, $window) {
    return {
      service: function(service) {

        var jvent = new $window.Jvent();

        var eventService = {
          forward: function($scope) {

            var events = Array.prototype.slice.call(arguments, 1);

            var options = _.isObject(_.last(events)) ? events.pop() : {},
                prefix = options.prefix || '';

            _.each(events, function(event) {

              var forwardBroadcast = function() {
                Array.prototype.unshift.call(arguments, prefix + event);
                $scope.$broadcast.apply($scope, arguments);
              };

              jvent.on(event, forwardBroadcast);

              $scope.$on('destroy', function() {
                jvent.off(forwardBroadcast);
              });
            });
          }
        };

        _.each([ 'on', 'once', 'off', 'removeAllListeners', 'emit' ], function(method) {
          eventService[method] = _.bind(jvent[method], jvent);
        });

        return _.extend(eventService, service);
      }
    };
  })

;

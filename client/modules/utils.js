angular.module('probedock.utils', [])

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

  .factory('yaml', function($window) {
    return {
      dump: function(object) {
        return jsyaml.safeDump(object);
      }
    };
  })

;

angular.module('probedock.bootstrap').factory('bootstrap', function($log, $rootScope, eventUtils) {

  var service = eventUtils.service({
    size: null,

    setSize: function(size) {
      if (size != service.size) {

        var oldSize = service.size;
        service.size = size;
        service.emit('bootstrap.size', size, oldSize);
      }
    },

    forward: function($scope) {
      $scope.bootstrapSize = service.size;

      service.on('bootstrap.size', function(newSize) {
        $scope.bootstrapSize = newSize;
      })
    }
  });

  return service;
});

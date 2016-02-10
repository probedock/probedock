angular.module('probedock.appSettings').factory('appSettings', function(api, eventUtils) {

  var service = eventUtils.service({
    settings: {},

    forwardSettings: function($scope) {
      setAppSettings();

      service.forward($scope, 'changed', { prefix: 'appSettings.' });
      $scope.$on('appSettings.changed', setAppSettings);

      function setAppSettings() {
        $scope.appSettings = service.settings;
      }
    },

    updateSettings: updateSettings
  });

  api({
    url: '/appSettings'
  }).then(function(res) {
    updateSettings(res.data);
  });

  function updateSettings(settings) {
    service.settings = settings;
    service.emit('changed', settings);
  }

  return service;
});

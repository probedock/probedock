angular.module('probedock.settings.app', [ 'probedock.api', 'probedock.forms', 'probedock.utils' ])

  .factory('appSettings', function(api, eventUtils) {

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
  })

  .controller('AppSettingsCtrl', function(api, appSettings, forms, $scope) {

    appSettings.forwardSettings($scope);
    $scope.$watch('appSettings', reset);

    $scope.save = function() {
      api({
        method: 'PATCH',
        url: '/appSettings',
        data: $scope.modifiedAppSettings
      }).then(function(res) {
        $scope.appSettings = res.data;
        appSettings.updateSettings(res.data);
      });
    };

    $scope.changed = function() {
      return !forms.dataEquals($scope.appSettings, $scope.modifiedAppSettings);
    };

    $scope.reset = reset;

    function reset() {
      $scope.modifiedAppSettings = angular.copy($scope.appSettings);
    }
  })

;

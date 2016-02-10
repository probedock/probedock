angular.module('probedock.appSettingsPage').controller('AppSettingsPageCtrl', function(api, appSettings, forms, $scope) {

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
});

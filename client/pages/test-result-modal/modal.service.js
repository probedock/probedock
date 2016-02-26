angular.module('probedock.testResultModal').service('testResultModal', function($modal) {
  return {
    open: function($scope) {
      var modal = $modal.open({
        templateUrl: '/templates/pages/test-result-modal/modal.template.html',
        scope: $scope,
        size: 'lg'
      });

      $scope.$on('$stateChangeStart', function() {
        modal.dismiss('stateChange');
      });

      return modal;
    }
  };
});

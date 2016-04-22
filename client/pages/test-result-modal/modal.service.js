angular.module('probedock.testResultModal').service('testResultModal', function(states, $uibModal) {
  return {
    open: function($scope) {
      var modal = $uibModal.open({
        templateUrl: '/templates/pages/test-result-modal/modal.template.html',
        scope: $scope,
        size: 'lg'
      });

      states.onStateChangeStart($scope, true, function() {
        modal.dismiss('stateChange');
      });

      return modal;
    }
  };
});

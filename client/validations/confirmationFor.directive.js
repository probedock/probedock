angular.module('probedock.confirmationForValidation', []).directive('confirmationFor', function() {
  return {
    require: 'ngModel',
    scope: {
      confirmationFor: '='
    },
    link: function(scope, element, attrs, ctrl) {
      ctrl.$validators.confirmationFor = function(modelValue) {
        return (modelValue || false) == (scope.confirmationFor || false);
      };
    }
  };
});

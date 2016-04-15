angular.module('probedock.projectRepoUrlValidation', []).directive('projectRepoUrl', function() {
  return {
    require: 'ngModel',
    link: function(scope, element, attrs, ctrl) {
      ctrl.$validators.projectRepoUrl = function(modelValue) {
        return _.isBlank(modelValue) || !_.isNull(modelValue.match(/^http(s):\/\/.*$/));
      };
    }
  };
});

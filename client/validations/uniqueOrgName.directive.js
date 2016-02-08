angular.module('probedock.uniqueOrgNameValidation', [ 'probedock.api' ]).directive('uniqueOrgName', function(api, $q) {
  return {
    require: 'ngModel',
    link: function(scope, elm, attrs, ctrl) {

      ctrl.$asyncValidators.uniqueOrgName = function(modelValue, viewValue) {

        // If the name is blank or is the same as the previous name,
        // then there can be no name conflict with another organization.
        if (_.isBlank(modelValue) || (_.isPresent(scope.organization.name) && modelValue == scope.organization.name)) {
          return $q.when();
        }

        return api({
          url: '/organizations',
          params: {
            name: modelValue,
            pageSize: 1
          }
        }).then(function(res) {
          // value is invalid if a matching organization is found (length is 1)
          return $q[res.data.length ? 'reject' : 'when']();
        }, function() {
          // consider value valid if uniqueness cannot be verified
          return $q.when();
        });
      };
    }
  };
});

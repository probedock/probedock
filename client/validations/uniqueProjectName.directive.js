angular.module('probedock.uniqueProjectNameValidation', [ 'probedock.api' ]).directive('uniqueProjectName', function(api, $q) {
  return {
    require: 'ngModel',
    link: function(scope, elm, attrs, ctrl) {

      ctrl.$asyncValidators.uniqueProjectName = function(modelValue, viewValue) {

        // If the name is blank or is the same as the previous name,
        // then there can be no name conflict with another organization.
        if (_.isBlank(modelValue) || (_.isPresent(scope.project.name) && modelValue == scope.project.name)) {
          return $q.when();
        }

        return api({
          url: '/projects',
          params: {
            name: api.slugify(modelValue),
            organizationId: scope.project.organizationId,
            pageSize: 1,
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

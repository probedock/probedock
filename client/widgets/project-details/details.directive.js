angular.module('probedock.projectDetailsWidget').directive('projectDetailsWidget', function() {
  return {
    restrict: 'E',
    templateUrl: '/templates/widgets/project-details/details.template.html',
    scope: {
      organization: '=',
      project: '='
    }
  };
});

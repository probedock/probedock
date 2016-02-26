angular.module('probedock.projectHealthWidget').directive('projectHealthWidget', function() {
  return {
    restrict: 'E',
    templateUrl: '/templates/widgets/project-health/health.template.html',
    scope: {
      organization: '=',
      project: '='
    }
  };
});

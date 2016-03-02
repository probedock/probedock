angular.module('probedock.projectHealthWidget').directive('projectHealthWidget', function() {
  return {
    restrict: 'E',
    templateUrl: '/templates/widgets/project-health/health.template.html',
    controller: 'ProjectHealthWidgetCtrl',
    scope: {
      organization: '=',
      project: '=',
      linkToVersion: '='
    }
  };
}).controller('ProjectHealthWidgetCtrl', function($scope) {
  _.defaults($scope, {
    linkToVersion: true
  });
});

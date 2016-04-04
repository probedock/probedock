angular.module('probedock.projectDetailsWidget').directive('projectDetailsWidget', function() {
  return {
    restrict: 'E',
    templateUrl: '/templates/widgets/project-details/details.template.html',
    controller: 'ProjectDetailsWidgetCtrl',
    scope: {
      organization: '=',
      project: '='
    }
  };
}).controller('ProjectDetailsWidgetCtrl', function($scope, orgs) {
  orgs.addAuthFunctions($scope);
});

angular.module('probedock.projectStateWidget').directive('projectStateWidget', function () {
    return {
        restrict: 'E',
        templateUrl: '/templates/widgets/project-state/state.template.html',
        scope: {
            organization: '='
        }
    }
}).directive('projectStateWidgetContent', function () {
    return {
        restrict: 'E',
        templateUrl: '/templates/widgets/project-state/state.content.template.html',
        controller: 'ProjectStateContentCtrl',
        scope: {
            organization: '='
        }
    }
});
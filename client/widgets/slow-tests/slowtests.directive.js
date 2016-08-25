angular.module('probedock.slowTestsWidget').directive('slowTestsWidget', function () {
    return {
        restrict: 'E',
        templateUrl: '/templates/widgets/slow-tests/slowtests.template.html',
        scope: {
            organization: '=',
            project: '='
        }
    }
}).directive('slowTestsWidgetContent', function () {
    return {
        restrict: 'E',
        templateUrl: '/templates/widgets/slow-tests/slowtests.content.template.html',
        controller: 'SlowTestsContentCtrl',
        scope: {
            organization: '=',
            project: '='
        }
    }
});
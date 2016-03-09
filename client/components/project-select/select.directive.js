angular.module('probedock.projectSelect').directive('projectSelect', function() {
  return {
    restrict: 'E',
    controller: 'ProjectSelectCtrl',
    templateUrl: '/templates/components/project-select/select.template.html',
    scope: {
      organization: '=',
      modelObject: '=',
      modelProperty: '@',
      prefix: '@',
      placeholder: '@',
      noLabel: '=?'
    }
  };
}).controller('ProjectSelectCtrl', function(api, $scope) {
  if (!$scope.prefix) {
    throw new Error("The prefix attribute on project-select directive is not set.");
  }

  _.defaults($scope, {
    modelProperty: 'projectIds',
    placeholder: 'All projects',
    noLabel: false,
    projectChoices: []
  });

  $scope.fetchProjectChoices = function(projectName) {
    var params = {
      organizationId: $scope.organization.id
    };

    if (projectName) {
      params.search = projectName;
    }

    api({
      url: '/projects',
      params: params
    }).then(function(res) {
      $scope.projectChoices = res.data;
    });
  }
});

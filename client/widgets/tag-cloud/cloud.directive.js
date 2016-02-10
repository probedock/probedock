angular.module('probedock.tagCloudWidget').directive('tagCloudWidget', function() {
  return {
    restrict: 'E',
    controller: 'TagCloudWidgetCtrl',
    templateUrl: '/templates/widgets/tag-cloud/cloud.template.html',
    scope: {
      organization: '='
    }
  };
}).controller('TagCloudWidgetCtrl', function(api, $scope) {

  $scope.$watch('organization', function(value) {
    if (value) {
      fetchTags().then(showTags);
    }
  });

  function fetchTags() {
    return api({
      url: '/tags',
      params: {
        organizationId: $scope.organization.id
      }
    });
  }

  function showTags(response) {
    $scope.tags = _.reduce(response.data, function(memo, tag) {

      memo.push({
        text: tag.name,
        weight: tag.testsCount
      });

      return memo;
    }, []);
  }
});

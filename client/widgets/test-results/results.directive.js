angular.module('probedock.testResultsWidget').directive('testResultsWidget', function() {
  return {
    restrict: 'E',
    controller: 'TestsResultsWidgetCtrl',
    templateUrl: '/templates/widgets/test-results/results.template.html',
    scope: {
      organization: '=',
      test: '='
    }
  };
}).controller('TestsResultsWidgetCtrl', function(api, $scope, testResultModal) {

  var page = 1;

  $scope.params = {};
  $scope.results = [];
  $scope.loading = true;
  $scope.pageSize = 100;

  $scope.$watch('test', function(value) {
    if (value) {
      initFetchResults();
    }
  });

  $scope.$watch('params', function(value) {
    if (!_.isEmpty(value)) {
      initFetchResults();
    }
  }, true);

  $scope.resultClass = function(result) {
    var classes = [];

    classes.push(result.newTest ? 'nt' : 'et');

    if (result.active) {
      classes.push(result.passed ? 'p' : 'f');
    } else {
      classes.push('i');
    }

    return classes.join(' ');
  };

  $scope.open = function(result) {
    $scope.result = result;
    testResultModal.open($scope);
  };

  $scope.fetchMore = function() {
    if ($scope.pagination.hasMorePages) {
      page++;
      fetchResults();
    }
  };

  function initFetchResults() {
    $scope.results = [];
    page = 1;
    fetchResults();
  }

  function fetchResults() {
    if (_.isUndefined($scope.test)) {
      return;
    }

    var params = {
      sort: 'runAt',
      page: page,
      pageSize: $scope.pageSize,
      testId: $scope.test.id
    };

    if ($scope.params.projectVersion) {
      params.projectVersionId = $scope.params.projectVersion.id
    }

    if ($scope.params.userIds) {
      params.runnerIds = $scope.params.userIds;
    }

    $scope.loading = true;

    return api({
      url: '/results',
      params: params
    }).then(function(response) {
      if (response.data) {
        $scope.pagination = response.pagination();
        $scope.results = $scope.results.concat(response.data);
        $scope.loading = false;
      }
    });
  }
});

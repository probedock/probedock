angular.module('probedock.testExecutionTimeWidget').directive('testExecutionTimeWidget', function() {
  return {
    restrict: 'E',
    controller: 'TestExecutionTimeWidgetCtrl',
    templateUrl: '/templates/widgets/test-execution-time/time.template.html',
    scope: {
      organization: '=',
      test: '='
    }
  };
}).controller('TestExecutionTimeWidgetCtrl', function(api, $scope, projectVersions) {

  var page = 1;

  $scope.pageSize = 25;
  $scope.maxResults = 100;

  $scope.params = {};
  $scope.results = [];
  $scope.loading = true;

  $scope.chart = {
    data: [],
    labels: [],
    options: {
      pointHitDetectionRadius: 5,
      showTooltips: false,
      pointDot: false,
      datasetFill: false,
      scaleShowVerticalLines: false,

      /*
       * Fix for space issue in the Y axis labels
       * see: https://github.com/nnnick/Chart.js/issues/729
       * see: http://stackoverflow.com/questions/26498171/how-do-i-prevent-the-scale-labels-from-being-cut-off-in-chartjs
       */
      scaleLabel: function (object) {
        return '  ' + object.value;
      }
    }
  };


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

        // Reverse and prepend the test results
        $scope.results = response.data.reverse().concat($scope.results);

        // Calculate the next number of results to load
        $scope.total = $scope.pagination.total > $scope.maxResults ? $scope.maxResults : $scope.pagination.total;
        var remainingResults = $scope.total - $scope.results.length;
        $scope.nextChunk = remainingResults > $scope.pageSize ? $scope.pageSize : remainingResults;

        showResults();

        $scope.loading = false;
      }
    });
  }

  function showResults() {
    var series = [];
    $scope.chart.data = [ series ];
    $scope.chart.labels.length = 0;

    _.each($scope.results, function(result) {
      //if ($scope.results[0] == result || $scope.results[$scope.results.length - 1] == result) {
      //  console.log(result.runAt);
      //  $scope.chart.labels.push(moment(result.runAt).format('DD.MM.YYYY<br />HH:mm:ss'));
      //}
      //else {
        $scope.chart.labels.push('');
      //}
      series.push(result.duration);
    });
  }
});

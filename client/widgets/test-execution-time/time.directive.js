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
  var reset = true;

  _.defaults($scope, {
    pageSize: 50,
    params: {},
    results: [],
    loading: true,
    started: false,
    chart: {
      data: [],
      labels: [],
      options: {
        showTooltips: false,
        pointDot: false,
        datasetFill: false,
        scaleShowVerticalLines: false
      }
    }
  });

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

  $scope.fetchNext = function() {
    if (page > 1) {
      page--;
      fetchResults();
    }
  };

  $scope.fetchPrev = function() {
    if (page < $scope.pagination.numberOfPages) {
      page++;
      fetchResults();
    }
  };

  function initFetchResults() {
    reset = true;
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
      $scope.pagination = response.pagination();

      var results = response.data.reverse();

      // Check if the received results must be completed by the previous ones
      // and then complete by previous ones
      if (!reset && results.length < $scope.pageSize) {
        results = results.concat($scope.results.slice(0, $scope.pageSize - results.length));
      }

      $scope.results = results;

      // Shortcuts to show prev/next buttons
      $scope.hasNext = $scope.pagination.page > 1;
      $scope.hasPrev = $scope.pagination.page < $scope.pagination.numberOfPages;

      var xSum =0, ySum = 0, xySum = 0, xxSum = 0;

      // Extract the min, max and sum of durations
      $scope.stats = _.reduce($scope.results, function(memo, result, idx) {
        memo.sum += result.duration;

        if (memo.maxDuration == null) {
          memo.maxDuration = result.duration;
          memo.minDuration = result.duration;
          return memo;
        }

        if (result.duration > memo.maxDuration) {
          memo.maxDuration = result.duration;
        }

        if (result.duration < memo.minDuration) {
          memo.minDuration = result.duration;
        }

        // Calculate the different sum for the next part of the regression calculation
        xSum += idx;
        ySum += result.duration;
        xySum += idx * result.duration;
        xxSum += idx * idx;

        return memo;
      }, {minDuration: null, maxDuration: null, sum: 0});

      // Calculate the regression coefs
      var a = ($scope.results.length * xySum - xSum * ySum) / ($scope.results.length * xxSum - xSum * xSum);
      var b = (ySum - a * xSum) / $scope.results.length;

      // Calculate the points of the regression line
      $scope.regression = [];
      for (var i = 0; i < $scope.results.length; i++) {
        $scope.regression.push(a * i + b);
      }

      // Calculate the average of durations
      $scope.stats.averageDuration = $scope.stats.sum / $scope.results.length;

      // Calculate the range of results shown
      var base = $scope.pagination.total - ((page - 1) * $scope.pageSize);
      var corr = base < $scope.pageSize ? $scope.pageSize - base : 0;
      $scope.range = {
        up: base + corr,
        down : base - $scope.pageSize + corr + 1
      };

      showResults();

      $scope.loading = false;
      $scope.started = true;
      reset = false;
    });
  }

  function showResults() {
    var series = [],
        avgSeries = [];
    $scope.chart.data = [ series, avgSeries, $scope.regression ];
    $scope.chart.labels.length = 0;

    _.each($scope.results, function(result) {
      $scope.chart.labels.push('');
      series.push(result.duration);
      avgSeries.push($scope.stats.averageDuration);
    });
  }
});

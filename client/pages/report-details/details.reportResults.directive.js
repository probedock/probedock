angular.module('probedock.reportDetailsPage').directive('reportDetailsResults', function() {
  return {
    restrict: 'E',
    controller: 'ReportDetailsResultsCtrl',
    templateUrl: '/templates/pages/report-details/details.reportResults.template.html',
    scope: {
      organization: '=',
      report: '=',
      resultsFilters: '='
    }
  };
}).controller('ReportDetailsResultsCtrl', function(api, $scope) {

    var page = 1,
        pageSize = 50;

    $scope.showingAllResults = false;
    $scope.fetchingMoreResults = false;
    $scope.noMoreResults = false;

    fetchResults().then(addResults);

    $scope.showAllResults = function() {
      $scope.showingAllResults = true;
    };

    $scope.showMoreResults = function() {
      page++;
      fetchResults().then(addResults);
    };

    $scope.resultClasses = function(result) {

      var classes = [];
      classes.push(result.newTest ? 'nt' : 'et');

      if (result.active) {
        classes.push(result.passed ? 'p' : 'f');
      } else {
        classes.push('i');
      }

      if (result.category) {
        var i = $scope.report.categories.indexOf(result.category);
        if (i >= 0) {
          classes.push('c-' + i.toString(36));
        }
      }

      if (result.tags && result.tags.length) {
        _.each(result.tags, function(tag) {
          var i = $scope.report.tags.indexOf(tag);
          if (i >= 0) {
            classes.push('t-' + i.toString(36));
          }
        });
      }

      if (result.tickets && result.tickets.length) {
        _.each(result.tickets, function(ticket) {
          var i = $scope.report.tickets.indexOf(ticket);
          if (i >= 0) {
            classes.push('i-' + i.toString(36));
          }
        });
      }

      return classes.join(' ');
    };

    $scope.testAnchor = function(result) {
      if (result.key) {
        return 'test-k-' + result.key;
      } else {
        return 'test-n-' + result.name.replace(/\s+/g, '').replace(/[^A-Za-z0-9\_\-]/g, '');
      }
    };

    function fetchResults() {

      $scope.fetchingMoreResults = true;

      return api({
        url: '/results',
        params: {
          reportId: $scope.report.id,
          page: page,
          pageSize: pageSize
        }
      });
    }

    function addResults(response) {

      $scope.fetchingMoreResults = false;
      $scope.total = response.pagination().total;

      if (!$scope.results) {
        $scope.results = response.data;
      } else {
        $scope.results = $scope.results.concat(response.data);
      }

      $scope.noMoreResults = $scope.results.length >= $scope.total || !response.data.length;

      if (response.data.length) {
        $scope.$broadcast('report.moreResultsLoaded');
      }
    }
  })

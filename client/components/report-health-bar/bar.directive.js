angular.module('probedock.reportHealthBar').directive('reportHealthBar', function() {
  return {
    restrict: 'E',
    controller: 'ReportHealthBarCtrl',
    templateUrl: '/templates/components/report-health-bar/bar.template.html',
    scope: {
      report: '=',
      clickForDetails: '@',
      percentageMinimumThreshold: '@'
    }
  };
}).controller('ReportHealthBarCtrl', function($attrs, reports, $scope) {
  _.defaults($scope, {
    percentageMinimumThreshold: 5
  });

  $scope.percentages = reports.percentages($scope.report);
  $scope.widthPercentages = effectiveWidths($scope.percentages);

  // $scope.widthPercentages = _.reduce($scope.percentages, function(memo, percentage, key) {
  //   memo[key] = effectiveWidth(percentage);
  //   return memo;
  // }, {});

  $scope.tooltipText = tooltipText($scope.report, $attrs.clickForDetails !== undefined);

  function tooltipText(report, clickForDetails) {

      var tooltipText = [],
          numberPassed = report.passedResultsCount - report.inactivePassedResultsCount,
          numberInactive = report.inactiveResultsCount,
          numberFailed = report.resultsCount - numberPassed - numberInactive;

      if (numberPassed) {
        tooltipText.push(numberPassed + ' passed');
      }
      if (numberFailed) {
        tooltipText.push(numberFailed + ' failed');
      }
      if (numberInactive) {
        tooltipText.push(numberInactive + ' inactive');
      }

      tooltipText = tooltipText.join(', ');
      if (clickForDetails) {
        tooltipText += '. Click to see the detailed report.';
      }

      return tooltipText;
  }

  /**
   * Calculate the width percentages based on a minimum threshold.
   *
   * The logic to make the magic happen is quite complex but generic.
   * It will take care the addition to new bars.
   *
   * @param percentages The percentages to check
   * @returns {*} The effective width percentages
   */
  function effectiveWidths(percentages) {
    /**
     * Keep track of the amount of percentage we have to reduce in other widths.
     * This will ensure later that we will not have a width sum > 100%.
     */
    var percentageToReduce = 0;

    /**
     * These percentages can be reduced to make sure the 100% rule
     */
    var reducablePercentages = {};

    /**
     * These percentages are considered as fixed
     */
    var fixedPercentages = {};

    // Iterate over each original percentage
    _.each(percentages, function(percentage, name) {
      // Check if the percentage is less than the threshold but we want to keep 0% untouched
      if (percentage > 0 && percentage < $scope.percentageMinimumThreshold) {
        percentageToReduce += $scope.percentageMinimumThreshold - percentage;
        fixedPercentages[name] = $scope.percentageMinimumThreshold;
      } else if (percentage == 0 && percentage < $scope.percentageMinimumThreshold + (percentageToReduce + percentage) / (_.size(reducablePercentages) + 1)) {
        // Consider the percentage as fixed if 0% or if the percentage is less than the threshold minus
        // the maximum value that we will remove form the percentage later. We consider this case
        // as it will not be possible to subtract the percentageToReduce and being greater than or equal
        // to the threshold
        fixedPercentages[name] = percentage;
      } else {
        // Consider the percentage reducable
        reducablePercentages[name] = percentage;
      }
    });

    // Calculate the amout to reduce to all the elements that can be reduced
    percentageToReduce = percentageToReduce / _.size(reducablePercentages);

    // Finally, iterates over remaining percentages to reduce them and match the 100% sum rule
    _.each(reducablePercentages, function(percentage, name) {
      fixedPercentages[name] = percentage - percentageToReduce;
    });

    return fixedPercentages;
  }
});

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
  $scope.widthPercentages = _.reduce(
    effectiveWidths(_.map($scope.percentages, function(percentage, name) { return { name: name, value: percentage }; })),
    function(memo, percentage) {
      memo[percentage.name] = percentage.value;
      return memo;
    },
    {}
  );

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
   * There is an example of the algorithm applied:
   *
   * Percentages = [
   *   { name: a, value: 16.8 },
   *   { name: b, value: 3 },
   *   { name: c, value: 25 },
   *   { name: d: value: 5.2 },
   *   { name: e, value: 1 },
   *   { name: f, value: 44 },
   *   { name: g, value: 5 }
   * ]
   *
   * Threshold: 5
   *
   * Sum increased percentage: 0
   * Sum decreased percentage: 0
   *
   * 1. First, the percentages are ordered (key are shortened to first letter):
   *
   *  [{ n: a, v: 1 }, { n: b, v: 3 }, { n: g, v: 5 }, { n: d, v: 5.2 }, { n: a, v: 16.8 }, { n: c, v: 25 }, { n: f, v: 44 }]
   *
   * 2. We sum the percentages that are greater than the threshold. In this example, we will sum d, a, c and f
   *    sum of reducable percentages: 7 + 15 + 25 + 44 = 91
   *
   * 2. Then we iterates over the sorted array. At each step we store the resulting percentage.
   *  a. For { n: a, v: 1 }
   *    if 1 <= 5 -> we need to increase from 1 to 5 the percentage. Sum increased percentage = previous sum + 5 - 1 = 4
   *
   *  b. For { n: b, v: 3 }
   *    if 3 <= 5 -> same than (a), from 3 to 5. Sum increased percentage = previous sum + 5 - 3 = 6
   *
   *  c. For { n: g, v: 5 }
   *    if 5 <= 5 -> same than (a, b), from 5 to 5. Sum increased percentage = pervious sum + 5 - 5 = 6
   *
   *  d. For { n: d, v: 5.2 }
   *    else -> we want to try to reduce the percentage proportionally.
   *      (We use the sum of reducable percentages): 6 / 91 * 5.2 = 0.3428
   *      then we reduce the percentage: 5.2 - 0.3428 = 4.8572
   *
   *      We are in a case where the reduction implies that we are lesser than the threshold then we fix to the threshold
   *      So the final percentage for this step is: 5
   *
   *      We update the sum of decreased percentage: previous sum + original percentage - new percentage -> 0 + 5.2 - 5 = 0.2
   *
   *  e. For { n: a, v: 16.8 }
   *    else -> same as (d)
   *      16.8 - (6 / 91 * 16.8) = 16.8 - 1.1076 = 15.6924
   *      sum of decreased percentage: 0.2 + 1.1076 = 1.3076
   *
   *  f. For { n: c, v: 25 }
   *    else -> same as (d, e)
   *      25 - (6 / 91 * 25) = 25 - 1.6483 = 23.3517
   *      sum of decreased percentage: 1.3076 + 1.6483 = 2.9559
   *
   *  g. For { n: f, v: 44 }
   *    else -> same as (d, e, f)
   *      44 - (6 / 91 * 44) = 44 - 2.9010 = 41.099
   *      sum of decreased percentage: 2.9559 + 2.9010 = 5.8569
   *
   *  At this stage we have fixed as best effort the maximum of percentages. We try to make a last adjustment and if we
   *  fail, we return the original percentages as it is not possible to correct the percentage.
   *
   *  3. We check if we have remaining percentage that has not been reduced.
   *    if 5.8569 < 6 -> Remains percentage that was not reduced
   *      we reduce the last percentage of the array from the remaining difference:
   *      { n: f, v: 41.099 } -> 41.099 - (6 - 5.8569) = 40.9549
   *
   *      We check if we respect the threshold constraint
   *      if 40.9549 < 5 -> No, we can return the fixed percentages
   *
   * @param percentages The percentages. The expected format is [{ name: ..., value: ... }]
   * @returns {*} The effective width percentages
   */
  function effectiveWidths(percentages) {
    /**
     * The sum of the increase of differences between percentage and threshold
     */
    var sumIncreasedPercentage = 0.0;

    /**
     * The sum of differences between percentage and reduced percentage
     */
    var sumReducedPercentage = 0.0;

    /**
     * The map sorted is a copy of the original.
     */
    var sortedPercentages = _.sortBy(percentages, 'value');

    /**
     * Calculate the sum of percentages that are greater than threshold
     */
    var sumReducablePercentages = _.reduce(sortedPercentages, function(memo, percentage) {
      if (percentage.value > $scope.percentageMinimumThreshold) {
        memo += percentage.value;
      }

      return memo;
    }, 0.0);

    var correctedPercentages = [];

    /**
     * Corrects the percentages that are less than the threshold
     *
     * The list is ordered and then some assumption are possible about the conditions
     * In case we enter in the final else, we know that we will not have any other
     * percentage to correct. In other words, the remaining percentages are greater
     * than the threshold.
     */
    _.each(sortedPercentages, function(percentage) {
      if (percentage.value == 0.0) {
        // When the percentage is equal to zero, we do nothing special
        correctedPercentages.push(percentage);
      }
      else if (percentage.value <= $scope.percentageMinimumThreshold) {
        // When the percentage is less than or equal to the threshold we
        // fix it to the threshold and sum the difference.
        sumIncreasedPercentage += $scope.percentageMinimumThreshold - percentage.value;
        percentage.value = $scope.percentageMinimumThreshold;
        correctedPercentages.push(percentage);
      }
      else {
        // We calculate the reduction
        var reduction = ((sumIncreasedPercentage / sumReducablePercentages) * percentage.value);

        // We calculate the reduced percentage
        // Example: 25 - (6 / 91 * 25) = 25 - 1.6483 = 23.3517
        var reducedPercentage = percentage.value - reduction;

        // We check if the reduction is less than the threshold.
        // In this case, we reduce only to the threshold.
        if (reducedPercentage < $scope.percentageMinimumThreshold) {
          reducedPercentage = $scope.percentageMinimumThreshold;
        }

        // We sum the amount we reduced
        sumReducedPercentage += percentage.value - reducedPercentage;

        // Finally we update the percentage value
        percentage.value = reducedPercentage;
        correctedPercentages.push(percentage);
      }
    });

    // Once we have iterated over all the percentages, we check that we have no remaining
    // percentage left to reduce. If this the case, we reduce the remaining value from the
    // last percentage.
    if (sumReducedPercentage < sumIncreasedPercentage) {
      // We calculate the corrected last percentage
      var lastReducedPercentage = correctedPercentages[correctedPercentages.length - 1].value - sumReducedPercentage;

      // We do one last check to make sure the threshold constraint is respected.
      // If this is not respected, we return the original percentages
      if (lastReducedPercentage < $scope.percentageMinimumThreshold) {
        return percentages;
      }
    }

    return correctedPercentages;
  }
});

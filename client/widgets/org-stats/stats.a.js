/**
 * Shows the metrics specific to an organization with the total of the database metrics for comparison.
 * The proportion used by the specific organization is calculated based on the DB totals.
 * Currently, the metrics are displayed for the number of projects, tests, results and payloads. In the case of
 * the results, we also show a sparkline for the trend.
 */
angular.module('probedock.orgStatsWidget', [ 'probedock.api' ]);

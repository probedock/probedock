angular.module('probedock.reports', [ 'ngSanitize', 'probedock.api', 'probedock.orgs', 'probedock.state', 'probedock.tables' ])

  .factory('reports', function() {
    return {
      percentages: function(report) {

        var passed = Math.round((report.passedResultsCount - report.inactivePassedResultsCount) * 100 / report.resultsCount),
            inactive = Math.round(report.inactiveResultsCount * 100 / report.resultsCount);

        if (passed + inactive > 100) {
          inactive = 100 - passed;
        }

        return percentages = {
          passed: passed,
          inactive: inactive,
          failed: 100 - passed - inactive
        };
      }
    };
  })

  .controller('ReportHealthCtrl', function(api, $sce, $scope, $stateParams) {

    fetchHealth().then(showHealth);

    function fetchHealth() {
      return api({
        url: '/reports/' + $stateParams.id + '/health'
      });
    }

    function showHealth(response) {
      $scope.healthHtml = $sce.trustAsHtml(response.data.html);
    }
  })

  .controller('ReportResultsCtrl', function(api, $scope, $stateParams) {

    var page = 1,
        pageSize = 30;

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

    function fetchResults() {

      $scope.fetchingMoreResults = true;

      return api({
        url: '/reports/' + $stateParams.id + '/results',
        params: {
          page: page,
          pageSize: 30
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

  .controller('ReportsCtrl', function(api, orgs, $scope, states) {

    orgs.forwardData($scope);

    $scope.reportTabs = [];
    $scope.activeTabs = {};

    states.onState($scope, [ 'org.reports', 'org.reports.show' ], function(state, params) {
      if (state && state.name == 'org.reports.show') {
        openReportTab(params.id);
      } else {
        selectTab('latest');
      }
    });

    function openReportTab(reportId) {

      var tab = _.findWhere($scope.reportTabs, { id: reportId });
      if (!tab) {
        tab = { id: reportId, loading: true };
        $scope.reportTabs.push(tab);
      }

      selectTab(reportId);
    }

    function selectTab(id) {

      _.each($scope.activeTabs, function(value, key) {
        $scope.activeTabs[key] = false;
      });

      $scope.activeTabs[id] = true;
    }
  })

  .directive('reportDetails', function() {
    return {
      restrict: 'E',
      controller: 'ReportDetailsCtrl',
      templateUrl: '/templates/report-details.html',
      scope: {
        report: '='
      }
    };
  })

  .controller('ReportTabCtrl', function(api, $scope) {

    api({
      url: '/reports/' + $scope.reportTab.id
    }).then(function(res) {
      $scope.report = res.data;
      $scope.reportTab.loading = false;
    });

    $scope.reportTime = function() {
      if (!$scope.report) {
        return 'Loading...';
      }

      var reportTime = moment($scope.report.startedAt);

      if (reportTime.isAfter(moment().startOf('day'))) {
        reportTime = reportTime.format('HH:mm');
      } else if (reportTime.isAfter(moment().startOf('year'))) {
        reportTime = reportTime.format('MMM D HH:mm');
      } else {
        reportTime = reportTime.format('MMM D YYYY HH:mm');
      }

      var runners = _.first(_.pluck($scope.report.runners, 'name'), 3);
      return reportTime + ' by ' + runners.join(', ');
    };
  })

  .controller('ReportDetailsCtrl', function(api, $scope) {

    $scope.reportFilters = {
      showPassed: true,
      showFailed: true,
      showInactive: true,
      showExisting: true,
      showNew: true,
      categories: [],
      tags: [],
      tickets: []
    };

    $scope.hasFilters = function() {
      var f = $scope.reportFilters;

      var result =
        !f.showPassed ||
        !f.showFailed ||
        !f.showInactive ||
        !f.showExisting ||
        !f.showNew ||
        (!!f.name && !!f.name.length) ||
        !!f.categories.length ||
        !!f.tags.length ||
        !!f.tickets.length;

      return result;
    };

    $scope.$watch('reportFilters', function(value) {
      if (value && $scope.report) {
        $scope.$broadcast('report.filtersChanged', value);
      }
    }, true);

    $scope.$watch('report', function(report) {
      if (report) {
        showReport(report);
      }
    });

    $scope.testAnchor = function(result) {
      if (result.key) {
        return 'test-k-' + result.key;
      } else {
        return 'test-n-' + result.name.replace(/\s+/g, '').replace(/[^A-Za-z0-9\_\-]/g, '');
      }
    };

    function showReport(report) {

      $scope.report = report;

      var numberPassed = report.passedResultsCount - report.inactivePassedResultsCount,
          numberInactive = report.inactiveResultsCount,
          numberFailed = report.resultsCount - numberPassed - numberInactive;

      $scope.healthChart = {
        labels: [ 'passed', 'failed', 'inactive' ],
        data: [ numberPassed, numberFailed, numberInactive ],
        colors: [ '#62c462', '#ee5f5b', '#fbb450' ]
      };
    }
  })

  .controller('LatestReportsCtrl', function(api, reports, $scope, $stateParams, tables, $timeout) {

    tables.create($scope, 'reportsList', {
      url: '/reports',
      pageSize: 15,
      params: {
        organizationName: $stateParams.orgName,
        withRunners: 1,
        withProjects: 1,
        withProjectVersions: 1,
        withCategories: 1
      }
    });

    var hideNoNewReportsPromise,
        latestReport;

    $scope.$on('reportsList.refresh', function() {
      $scope.noNewReports = false;
      if (hideNoNewReportsPromise) {
        $timeout.cancel(hideNoNewReportsPromise);
      }
    });

    $scope.$on('reportsList.refreshed', function(event, list, table) {

      var records = list.records,
          initialized = list.initialized;

      if ((initialized && !records.length) || (latestReport && records.length && records[0].id == latestReport.id)) {
        $scope.noNewReports = true;
        hideNoNewReportsPromise = $timeout(function() {
          $scope.noNewReports = false;
        }, 5000);
      } else if (table.pagination.start === 0) {
        latestReport = _.first(records);
      }
    });
  })

  .directive('reportHealthBar', function() {

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

    return {
      restrict: 'E',
      scope: {
        report: '=',
        clickForDetails: '@'
      },
      controller: function($attrs, reports, $scope) {
        $scope.percentages = reports.percentages($scope.report);
        $scope.tooltipText = tooltipText($scope.report, $attrs.clickForDetails !== undefined);
      },
      templateUrl: '/templates/report-health-bar.html'
    };
  })

  .directive('reportFilters', function($timeout) {
    return {
      link: function($scope, element, attrs) {
        $scope.$on('report.filtersChanged', function(event, filters) {
          $timeout(function() {
            applyFilters(filters);
          });
        });

        $scope.$on('report.moreResultsLoaded', function() {
          $timeout(function() {
            applyFilters($scope.reportFilters);
          });
        });

        function applyFilters(filters) {

          var report = $scope[attrs.reportFilters],
              selector = attrs.reportFiltersSelector;

          if (!report || !selector) {
            return;
          }

          var filters = _.extend({}, filters);
          if (!filters.name || !filters.name.trim().length) {
            delete filters.name;
          }

          element[filters.showPassed ? 'removeClass' : 'addClass']('hidePassed');
          element[filters.showFailed ? 'removeClass' : 'addClass']('hideFailed');
          element[filters.showInactive ? 'removeClass' : 'addClass']('hideInactive');
          element[filters.showExisting ? 'removeClass' : 'addClass']('hideExisting');
          element[filters.showNew ? 'removeClass' : 'addClass']('hideNew');

          var elements = element.find(selector),
              elementsToHide = elements.filter(function() {
                var e = $(this);

                if (filters.name && e.data('n') && e.data('n').toLowerCase().indexOf(filters.name.toLowerCase()) < 0) {
                  return true;
                } else if (metadataMismatch(e, filters.categories, report.categories, 'c')) {
                  return true;
                } else if (metadataMismatch(e, filters.tags, report.tags, 't')) {
                  return true;
                } else if (metadataMismatch(e, filters.tickets, report.tickets, 'i')) {
                  return true;
                }

                return false;
              });

          elements.removeClass('h tmp-hidden');
          elementsToHide.addClass('h');

          if (element.find(selector + ':visible').length) {
            element.find('.no-match').hide();
          } else {
            element.find('.no-match').show();
          }
        }

        function metadataMismatch(element, items, allItems, classPrefix) {
          return items.length && !_.some(items, function(item) {
            return element.hasClass(classPrefix + '-' + allItems.indexOf(item).toString(36));
          });
        }
      }
    };
  })

  .directive('healthTooltips', function($compile, $document) {
    return function($scope, element, attrs) {

      var titleTemplate = _.template('<strong class="<%= titleClass %>"><%- title %></strong>'),
          contentTemplate = _.template('<ul class="list-unstyled"><li><strong>Duration:</strong> <%- duration %></li></ul>');

      element.on('click', 'a', function() {

        var e = $(this);

        var testElement;
        if (e.data('k')) {
          testElement = $('#test-k-' + e.data('k'));
        } else if (e.data('n')) {
          testElement = $('#test-n-' + e.data('n').replace(/\s+/g, '').replace(/[^A-Za-z0-9\_\-]/g, ''));
        }

        if (testElement.length) {
          $document.duScrollTo(testElement, 50, 1000);
        }
      });

      element.on('mouseenter', 'a', function() {

        var e = $(this);

        if (!e.data('bs.popover')) {

          var titleClass = 'text-success';

          if (e.is('.f')) {
            titleClass = 'text-danger';
          } else if (e.is('.i')) {
            titleClass = 'text-warning';
          }

          e.popover({
            trigger: 'hover manual',
            placement: 'auto',
            title: titleTemplate({ title: e.data('n'), titleClass: titleClass }),
            // FIXME: format duration
            content: contentTemplate({ duration: e.data('d') + 'ms' }),
            html: true
          });

          e.popover('show');
        }
      });
    };
  })

;

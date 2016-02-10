angular.module('probedock.reportDetailsPage').directive('reportFilters', function($timeout) {
  return {
    link: function($scope, element, attrs) {
      $scope.$on('report.filtersChanged', function(event, filters) {
        $timeout(function() {
          applyFilters(filters);
        });
      });

      $scope.$on('report.moreResultsLoaded', function() {
        $timeout(function() {
          applyFilters($scope[attrs.reportFiltersParams]);
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
});

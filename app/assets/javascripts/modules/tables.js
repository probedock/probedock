angular.module('probedock.tables', [])

  .factory('tables', function(api) {

    var service = {
      create: function($scope, name, options) {

        var list = $scope[name] = {
          initialized: false,
          records: []
        };

        list.refresh = function(table) {

          table.pagination.start = table.pagination.start || 0;
          table.pagination.number = table.pagination.number || options.pageSize || 15;

          var params = _.extend({}, options.params, {
            page: table.pagination.start / table.pagination.number + 1,
            pageSize: table.pagination.number
          });

          $scope.$broadcast(name + '.refresh');

          api({
            url: options.url,
            params: params
          }).then(updatePagination).then(updateRecords);

          function updatePagination(res) {
            table.pagination.numberOfPages = res.pagination().numberOfPages;
            return res;
          }

          function updateRecords(res) {
            list.records = res.data;
            $scope.$broadcast(name + '.refreshed', list, table);
            list.initialized = true;
          }
        };

        return list;
      }
    };

    return service;
  })

  .directive('refreshTable', function() {
    return {
      require: '^stTable',
      templateUrl: '/templates/refresh-table.html',
      link: function(scope, element, attrs, ctrl) {
        scope.refresh = function() {
          ctrl.slice(0, ctrl.tableState().pagination.number);
        };
      }
    };
  })

  .controller('PaginationCtrl', function($scope) {

    $scope.directPageLinks = [];

    $scope.$watchGroup([ 'currentPage', 'numPages' ], function(values) {

      var currentPage = values[0],
          numPages = values[1];

      if (numPages == 2) {
        $scope.directPageLinks = [ 1, 2 ];
      } else if (numPages && numPages >= 3 && currentPage) {
        if (currentPage == 1) {
          $scope.directPageLinks = [ 1, 2, 3 ];
        } else if (currentPage == numPages) {
          $scope.directPageLinks = _.times(3, function(i) {
            return currentPage - 2 + i;
          });
        } else {
          $scope.directPageLinks = _.times(3, function(i) {
            return currentPage - 1 + i;
          });
        }
      }
    });

  })

;

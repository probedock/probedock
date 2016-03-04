angular.module('probedock.tables').factory('tables', function(api) {

  var service = {
    create: function($scope, name, options) {

      var list = $scope[name] = {
        initialized: false,
        records: [],
        params: {}
      };

      list.refresh = function(table) {

        table.pagination.start = table.pagination.start || 0;
        table.pagination.number = table.pagination.number || options.pageSize || 15;

        var params = _.extend({}, options.params, list.params, {
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
});

angular.module('probedock.api').factory('apiPagination', function($log) {
  return function(res) {

    var pagination = {
      page: parsePaginationHeader(res, 'X-Pagination-Page', true),
      pageSize: parsePaginationHeader(res, 'X-Pagination-Page-Size', true),
      total: parsePaginationHeader(res, 'X-Pagination-Total', true),
      filteredTotal: parsePaginationHeader(res, 'X-Pagination-Filtered-Total', false),
      length: res.data.length
    };

    // Check if the filters have been applied
    pagination.numberOfPages = Math.ceil((pagination.filteredTotal !== undefined ? pagination.filteredTotal : pagination.total) / pagination.pageSize);
    pagination.hasMorePages = pagination.page * pagination.pageSize < (pagination.filteredTotal !== undefined ? pagination.filteredTotal : pagination.total) && pagination.length !== 0;

    return pagination;
  };

  function parsePaginationHeader(res, header, required) {

    var value = res.headers(header);
    if (!value) {
      if (required) {
        throw new Error('Expected response to have the ' + header + ' header');
      } else {
        return undefined;
      }
    }

    var number = parseInt(value, 10);
    if (isNaN(number)) {
      throw new Error('Expected response header ' + header + ' to contain an integer, got "' + value + '" (' + typeof(value) + ')');
    }

    return number;
  }
});

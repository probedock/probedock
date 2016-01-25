angular.module('probedock.api', [ 'probedock.auth', 'probedock.utils' ])

  .factory('api', function(apiPagination, auth, $http, $log, urls) {

    var counter = 0;

    var api = function(options) {
      options = _.extend({}, options);

      if (!options.url.match(/^https?:\/\//) && !options.url.match(/^\/\//)) {
        options.url = urls.join('/api', options.url);
      }

      // TODO: replace by $httpParamSerializerJQLike when upgrading to Angular 1.4
      if (options.params) {
        _.each(options.params, function(value, key) {
          if (_.isArray(value) && !key.match(/\[\]$/)) {
            options.params[key + '[]'] = value;
            delete options.params[key];
          }
        });
      }

      options.headers = _.defaults({}, options.headers, api.authHeaders());

      var n = ++counter;

      var logMessage = 'api ' + n + ' ' + (options.method || 'GET') + ' ' + options.url;
      logMessage += (options.params ? '?' + urls.queryString(options.params) : '');
      logMessage += (options.data ? ' ' + JSON.stringify(options.data) : '');
      $log.debug(logMessage);

      return $http(options).then(function(res) {

        res.pagination = function() {
          if (!res._pagination) {
            res._pagination = apiPagination(res);
            $log.debug('api ' + n + ' pagination: ' + JSON.stringify(res._pagination));
          }

          return res._pagination;
        };

        return res;
      });
    };

    api.authHeaders = function() {

      var headers = {};
      if (auth.token) {
        headers.Authorization = 'Bearer ' + auth.token;
      }

      return headers;
    };

    api.getResource = function(id, basePath) {
      return api({
        url: basePath + '/' + id
      });
    };

    api.patchResource = function(resource, basePath) {
      return api({
        method: 'PATCH',
        url: basePath + '/' + resource.id,
        data: resource
      }).then(function(res) {
        return res.data;
      });
    };

    api.deleteResource = function(resource, basePath) {
      return api({
        method: 'DELETE',
        url: basePath + '/' + resource.id
      });
    };

    api.compact = function(data) {
      return _.reduce(data, function(memo, value, attr) {

        if (value && value.length) {
          memo[attr] = value;
        }

        return memo;
      }, {});
    };

    api.pushOrUpdate = function(list, item) {

      var existingItem = _.findWhere(list, { id: item.id });

      if (existingItem) {
        list[list.indexOf(existingItem)] = item;
        return 0;
      } else {
        list.push(item);
        return 1;
      }
    };

    return api;
  })

  .factory('apiPagination', function($log) {
    return function(res) {

      var pagination = {
        page: parsePaginationHeader(res, 'X-Pagination-Page', true),
        pageSize: parsePaginationHeader(res, 'X-Pagination-Page-Size', true),
        total: parsePaginationHeader(res, 'X-Pagination-Total', true),
        filteredTotal: parsePaginationHeader(res, 'X-Pagination-Filtered-Total', false),
        length: res.data.length
      };

      pagination.numberOfPages = Math.ceil((pagination.filteredTotal || pagination.total) / pagination.pageSize);
      pagination.hasMorePages = pagination.page * pagination.pageSize < (pagination.filteredTotal !== undefined ? pagination.filteredTotal : pagination.total) && pagination.length !== 0;

      return pagination;
    };

    function parsePaginationHeader(res, header, required) {

      var value = res.headers(header);
      if (!value) {
        if (required) {
          throw new Error('Exected response to have the ' + header + ' header');
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
  })

;

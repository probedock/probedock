angular.module('probe-dock.api', ['probe-dock.auth'])

  .factory('api', function(auth, $http) {

    var api = function(options) {

      options = _.extend({}, options);

      if (!options.url.match(/^https?:\/\//)) {
        options.url = '/api/' + options.url.replace(/^\//, '');
      }

      if (auth.token) {
        options.headers = _.defaults({}, options.headers, {
          Authorization: 'Bearer ' + auth.token
        });
      }

      return $http(options);
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
      } else {
        list.push(item);
      }
    };

    return api;
  })

;

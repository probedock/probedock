angular.module('rox.api', ['rox.auth'])

  .factory('ApiService', ['AuthService', '$http', function($auth, $http) {
    return {
      http: function(options) {

        options.headers = _.defaults({}, options.headers, {
          Authorization: 'Bearer ' + $auth.token
        });

        return $http(options);
      },

      compact: function(data) {
        return _.reduce(data, function(memo, value, attr) {

          if (value && value.length) {
            memo[attr] = value;
          }

          return memo;
        }, {});
      }
    };
  }])

;

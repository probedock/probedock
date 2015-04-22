angular.module('probe-dock.forms', [])

  .factory('forms', function() {

    var service = {
      dataEquals: function(data1, data2) {
        if (_.isArray(data1) && _.isArray(data2)) {
          return data1.length == data2.length && _.every(data1, function(e, i) {
            return service.dataEquals(e, data2[i]);
          });
        } else if (_.isObject(data1) && _.isObject(data2)) {
          return _.every(_.union(_.keys(data1), _.keys(data2)), function(key) {
            return service.dataEquals(data1[key], data2[key]);
          });
        } else {
          return (data1 || false) == (data2 || false);
        }
      }
    };

    return service;
  })

  .directive('selectOnClick', function () {
    return {
      restrict: 'A',
      link: function (scope, element, attrs) {
        element.on('click', function () {
          this.select();
        });
      }
    };
  })

;

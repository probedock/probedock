angular.module('probedock.tables').directive('filter', function (stConfig, $timeout) {
  return {
    require: '^stTable',
    link: function (scope, element, attr, ctrl) {
      var tableCtrl = ctrl;
      var promise = null;
      var throttle = attr.stDelay || stConfig.search.delay;
      var event = attr.stInputEvent || stConfig.search.inputEvent;

      //table state -> view
      scope.$watch(function() {
        return _.deepFind(scope, attr.filter);
      }, function (newValue, oldValue) {
        filter(newValue, oldValue);
      }, true);

      // view -> table state
      element.bind(event, function (evt) {
        evt = evt.originalEvent || evt;
        if (promise !== null) {
          $timeout.cancel(promise);
        }

        promise = $timeout(function () {
          filter(_.deepFind(scope, attr.filter), null);
          promise = null;
        }, throttle);
      });

      function filter(newValue, oldValue) {
        if (!_.isEqual(newValue, oldValue)) {
          tableCtrl.tableState().search.filter = true;
          tableCtrl.search(newValue, _.last(attr.filter.split('.')));
        }
      }
    }
  };
});
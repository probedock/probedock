angular.module('probedock.tables').directive('refreshTable', function() {
  return {
    require: '^stTable',
    templateUrl: '/templates/services/tables/tables.refreshTable.template.html',
    replace: true,
    link: function(scope, element, attrs, ctrl) {
      scope.refresh = function() {
        ctrl.slice(0, ctrl.tableState().pagination.number);
      };
    }
  };
});

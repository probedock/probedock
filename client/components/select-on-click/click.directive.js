angular.module('probedock.selectOnClick').directive('selectOnClick', function() {
  return {
    restrict: 'A',
    link: function(scope, element, attrs) {
      element.on('click', function() {
        this.select();
      });
    }
  };
});

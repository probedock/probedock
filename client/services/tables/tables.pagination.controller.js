angular.module('probedock.tables').controller('TablePaginationCtrl', function($scope) {

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

});

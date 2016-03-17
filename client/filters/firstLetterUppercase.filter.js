angular.module('probedock.firstLetterUppercaseFilter', []).filter('firstLetterUppercase', function () {
  return function(str) {
    return str.charAt(0).toUpperCase() + str.slice(1);
  };
});

angular.module('probedock.testCategoriesBarWidget').factory('testCategoriesBar', function() {

  var colors = [ '#337AB7', '#5BC0DE', '#9966ff', '#D9534F', '#00cc99', '#ff9933', '#F0AD4E', '#99cc00', '#ccccff', '#339966' ];

  return {
    getColor: function(index) {
      return colors[index % (colors.length - 1)];
    }
  };
});

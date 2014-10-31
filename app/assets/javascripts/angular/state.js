angular.module('rox.state', [ 'ui.router' ])

  .config(['$locationProvider', '$urlRouterProvider', function($locationProvider, $urlRouterProvider) {
    $locationProvider.html5Mode(true);
    $urlRouterProvider.otherwise("/");
  }])

;

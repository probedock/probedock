angular.module('rox.routes', [ 'ui.router' ])

  .config(['$stateProvider', function($stateProvider) {

    $stateProvider

      .state('std', {
        abstract: true,
        template: '<div ui-view="navbar" /><div ui-view="content" />'
      })

      .state('std.home', {
        url: '^/',
        views: {
          'navbar@std': {
            templateUrl: '/templates/navbar.html'
          },
          'content@std': {
            templateUrl: '/templates/home.html'
          }
        }
      })
      
    ;

  }])

;

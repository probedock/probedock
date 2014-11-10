angular.module('rox.routes', [ 'ui.router' ])

  .config(['$stateProvider', function($stateProvider) {

    $stateProvider

      .state('std', {
        abstract: true,
        templateUrl: '/templates/main.html'
      })

      .state('std.home', {
        url: '^/',
        views: {
          'content@std': {
            templateUrl: '/templates/home.html'
          }
        }
      })

      .state('std.projects', {
        url: '/projects',
        views: {
          'content@std': {
            templateUrl: '/templates/projects.html'
          }
        }
      })

      .state('std.reports', {
        url: '/reports',
        views: {
          'content@std': {
            templateUrl: '/templates/reports.html'
          }
        }
      })

      .state('std.report', {
        url: '/reports/:reportId',
        views: {
          'content@std': {
            templateUrl: '/templates/report.html'
          }
        }
      })
      
    ;

  }])

;

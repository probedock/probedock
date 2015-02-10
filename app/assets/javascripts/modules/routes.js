angular.module('probe-dock.routes', [ 'ui.router' ])

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

      .state('std.profile', {
        url: '^/profile',
        views: {
          'content@std': {
            templateUrl: '/templates/profile.html'
          }
        }
      })

      .state('std.projects', {
        url: '^/projects',
        views: {
          'content@std': {
            templateUrl: '/templates/projects.html'
          }
        }
      })

      .state('std.reports', {
        url: '^/reports',
        views: {
          'content@std': {
            templateUrl: '/templates/reports.html'
          }
        }
      })

      .state('std.reports.details', {
        url: '/:reportId'
      })

      .state('std.users', {
        url: '^/users',
        views: {
          'content@std': {
            templateUrl: '/templates/users.html'
          }
        }
      })

      .state('std.users.details', {
        url: '/:userId'
      })
      
    ;

  }])

;

angular.module('probe-dock.routes', [ 'ui.router' ])

  .config(function($stateProvider, $urlRouterProvider) {

    $stateProvider

      .state('home', {
        url: '/',
        controller: 'HomeCtrl',
        templateUrl: '/templates/home.html'
      })

      .state('profile', {
        url: '/profile',
        templateUrl: '/templates/profile.html'
      })

      .state('users', {
        url: '/users',
        templateUrl: '/templates/users.html'
      })

      .state('users.details', {
        url: '/:userId'
      })

      .state('org', {
        url: '/:orgName',
        abstract: true,
        template: '<div ui-view />'
      })

      .state('org.dashboard', {
        url: '',
        abstract: true,
        templateUrl: '/templates/dashboard.html'
      })

      .state('org.dashboard.default', {
        url: '',
        templateUrl: '/templates/dashboard-default.html'
      })

      .state('org.dashboard.default.edit', {
        url: '/edit'
      })

      .state('org.dashboard.members', {
        url: '/members',
        controller: 'OrgMembersCtrl',
        templateUrl: '/templates/dashboard-members.html'
      })

      .state('org.info', {
        url: '/info',
        controller: 'OrgCtrl',
        templateUrl: '/templates/org.html'
      })

      .state('org.projects', {
        url: '/projects',
        templateUrl: '/templates/projects.html'
      })

      .state('org.reports', {
        url: '/reports',
        templateUrl: '/templates/reports.html'
      })

      .state('org.reports.details', {
        url: '/:reportId'
      })

    ;

    $urlRouterProvider.otherwise(function($injector) {
      $injector.get('$state').go('home');
    });

  })

;

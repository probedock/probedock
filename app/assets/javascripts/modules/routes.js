angular.module('probe-dock.routes', [ 'ui.router' ])

  .config(function($stateProvider, $urlRouterProvider) {

    $stateProvider

      .state('home', {
        url: '/',
        controller: 'HomeCtrl',
        templateUrl: '/templates/home.html'
      })

      .state('home.newOrg', {
        url: 'new'
      })

      .state('error', {
        url: '/error/:type',
        controller: 'ErrorPageCtrl',
        templateUrl: '/templates/error.html'
      })

      .state('help', {
        url: '/help',
        abstract: true,
        template: '<div ui-view />'
      })

      .state('help.gettingStarted', {
        url: '/getting-started?organizationId&projectId',
        controller: 'GettingStartedCtrl',
        templateUrl: '/templates/getting-started.html'
      })

      .state('newMembership', {
        url: '/new-member?otp',
        controller: 'NewMembershipCtrl',
        templateUrl: '/templates/new-membership.html'
      })

      .state('profile', {
        url: '/profile',
        templateUrl: '/templates/profile.html'
      })

      .state('profile.edit', {
        url: '/edit'
      })

      .state('admin', {
        url: '/admin',
        abstract: true,
        template: '<div ui-view />'
      })

      .state('admin.users', {
        url: '/users',
        templateUrl: '/templates/users.html'
      })

      .state('admin.users.show', {
        url: '/:id'
      })

      .state('admin.users.show.edit', {
        url: '/edit'
      })

      .state('org', {
        url: '/:orgName',
        abstract: true,
        template: '<div ui-view />'
      })

      .state('org.dashboard', {
        url: '',
        abstract: true,
        controller: 'DashboardCtrl',
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

      .state('org.dashboard.members.new', {
        url: '/new'
      })

      .state('org.dashboard.members.edit', {
        url: '/:id/edit'
      })

      .state('org.projects', {
        url: '/projects',
        controller: 'ProjectsCtrl',
        templateUrl: '/templates/projects.html'
      })

      .state('org.projects.new', {
        url: '/new'
      })

      .state('org.projects.edit', {
        url: '/edit?id'
      })

      .state('org.reports', {
        url: '/reports',
        controller: 'ReportsCtrl',
        templateUrl: '/templates/reports.html'
      })

      .state('org.reports.show', {
        url: '/:reportId'
      })

    ;

    $urlRouterProvider.otherwise(function($injector) {
      $injector.get('$state').go('home');
    });

  })

;

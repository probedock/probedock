angular.module('probedock.routes', [ 'probedock.states', 'ui.router' ])

  .config(function($stateProvider, $urlRouterProvider) {

    var titleElementLimit = 25;

    $stateProvider

      .state('home', {
        url: '/',
        controller: 'HomePageCtrl',
        templateUrl: '/templates/pages/home/home.template.html',
        resolve: {
          $title: function() { return buildTitle('Home'); }
        }
      })

      .state('home.newOrg', {
        url: 'new',
        resolve: {
          $title: function() { return buildTitle('Home', 'New organization'); }
        }
      })

      .state('error', {
        url: '/error/:type',
        controller: 'ErrorPageCtrl',
        templateUrl: '/templates/pages/error/error.template.html',
        resolve: {
          $title: function() { return buildTitle('Error'); }
        }
      })

      .state('permalinks', {
        url: '/go/:target',
        controller: 'PermalinksPageCtrl',
        templateUrl: '/templates/pages/permalinks/permalinks.template.html'
      })

      .state('help', {
        url: '/help',
        abstract: true,
        template: '<div ui-view />'
      })

      .state('help.gettingStarted', {
        url: '/getting-started?organizationId&projectId',
        controller: 'GettingStartedPageCtrl',
        templateUrl: '/templates/pages/getting-started/started.template.html',
        resolve: {
          $title: function() { return buildTitle('Help', 'Getting started'); }
        }
      })

      .state('newMembership', {
        url: '/new-member?otp',
        controller: 'MemberRegistrationPageCtrl',
        templateUrl: '/templates/pages/member-registration/registration.template.html',
        resolve: {
          $title: function() { return buildTitle('Join organization'); }
        }
      })

      .state('register', {
        url: '/register?otp',
        controller: 'UserRegistrationPageCtrl',
        templateUrl: '/templates/pages/user-registration/registration.template.html',
        resolve: {
          $title: function() { return buildTitle('Register'); }
        }
      })

      .state('confirmRegistration', {
        url: '/confirm-registration?otp',
        controller: 'UserConfirmRegistrationPageCtrl',
        templateUrl: '/templates/pages/user-confirm-registration/confirm.template.html',
        resolve: {
          $title: function() { return buildTitle('Confirm registration'); }
        }
      })

      .state('profile', {
        url: '/profile',
        templateUrl: '/templates/pages/profile/profile.template.html',
        resolve: {
          $title: function() { return buildTitle('Profile'); }
        }
      })

      .state('profile.edit', {
        url: '/edit',
        resolve: {
          $title: function() { return buildTitle('Edit profile'); }
        }
      })

      .state('admin', {
        url: '/admin',
        abstract: true,
        template: '<div ui-view />'
      })

      .state('admin.users', {
        url: '/users',
        controller: 'UserListPageCtrl',
        templateUrl: '/templates/pages/user-list/list.template.html',
        resolve: {
          $title: function() { return buildTitle('Users'); }
        }
      })

      .state('admin.management', {
        url: '/management',
        controller: 'ManagementPageCtrl',
        templateUrl: '/templates/pages/management/management.template.html',
        resolve: {
          $title: function() { return buildTitle('Management'); }
        }
      })

      .state('admin.settings', {
        url: '/settings',
        controller: 'AppSettingsPageCtrl',
        templateUrl: '/templates/pages/app-settings/settings.template.html',
        resolve: {
          $title: function() { return buildTitle('Settings'); }
        }
      })

      .state('admin.users.show', {
        url: '/:id',
        resolve: {
          routeUserId: function($stateParams) {
            return $stateParams.id;
          },
          $title: function($stateParams) { return buildTitle('Users', $stateParams.id); }
        }
      })

      .state('admin.users.show.edit', {
        url: '/edit',
        resolve: {
          $title: function(routeUserId) { return buildTitle('Users', routeUserId, 'Edit'); }
        }
      })

      .state('org', {
        url: '/:orgName',
        abstract: true,
        template: '<div ui-view />',
        resolve: {
          routeOrgName: function($stateParams) {
            return $stateParams.orgName;
          }
        }
      })

      .state('org.dashboard', {
        url: '',
        abstract: true,
        controller: 'DashboardPageCtrl',
        templateUrl: '/templates/pages/dashboard/dashboard.template.html'
      })

      .state('org.dashboard.default', {
        url: '',
        templateUrl: '/templates/pages/dashboard-default/default.template.html',
        resolve: {
          $title: function() { return buildTitle('Dashboard'); }
        }
      })

      .state('org.dashboard.default.edit', {
        url: '/edit',
        resolve: {
          $title: function() { return buildTitle('Dashboard', 'Edit organization'); }
        }
      })

      .state('org.dashboard.members', {
        url: '/members',
        controller: 'MemberListPageCtrl',
        templateUrl: '/templates/pages/member-list/list.template.html',
        resolve: {
          $title: function() { return buildTitle('Organization members'); }
        }
      })

      .state('org.dashboard.members.new', {
        url: '/new',
        resolve: {
          $title: function() { return buildTitle('Dashboard', 'Organization members', 'Add member'); }
        }
      })

      .state('org.dashboard.members.edit', {
        url: '/:id/edit',
        resolve: {
          $title: function($stateParams) { return buildTitle('Dashboard', 'Organization members', $stateParams.id, 'Edit'); }
        }
      })

      .state('org.projects', {
        abstract: true,
        template: '<div ui-view />'
      })

      .state('org.projects.list', {
        url: '/projects',
        controller: 'ProjectListPageCtrl',
        templateUrl: '/templates/pages/project-list/list.template.html',
        resolve: {
          $title: function() { return buildTitle('Projects'); }
        }
      })

      .state('org.projects.list.new', {
        url: '/new',
        resolve: {
          $title: function() { return buildTitle('Projects', 'New'); }
        }
      })

      .state('org.projects.list.edit', {
        url: '/edit?id',
        resolve: {
          $title: function($stateParams) { return buildTitle('Projects', $stateParams.id, 'Edit'); }
        }
      })

      .state('org.reports', {
        url: '/reports',
        controller: 'ReportListPageCtrl',
        templateUrl: '/templates/pages/report-list/list.template.html',
        resolve: {
          $title: function() { return buildTitle('Reports'); }
        }
      })

      .state('org.reports.show', {
        url: '/:id',
        resolve: {
          $title: function($stateParams) { return buildTitle('Reports', $stateParams.id); }
        }
      })

      .state('org.tests', {
        url: '/test',
        abstract: true,
        template: '<div ui-view />'
      })

      .state('org.tests.show', {
        url: '/:id',
        controller: 'TestDetailsPageCtrl',
        templateUrl: '/templates/pages/test-details/details.template.html',
        resolve: {
          $title: function($stateParams) { return buildTitle('Tests', $stateParams.id); }
        }
      })

      // Must be the last route to match any non-reserved word under /:orgName
      .state('org.projects.show', {
        url: '/:projectName',
        controller: 'ProjectDetailsPageCtrl',
        templateUrl: '/templates/pages/project-details/details.template.html',
        resolve: {
          $title: function($stateParams) { return buildTitle('Projects', $stateParams.projectName); }
        }
      })

      .state('org.projects.show.edit', {
        url: '/edit'
      })
    ;

    $urlRouterProvider.otherwise(function($injector) {
      $injector.get('$state').go('home');
    });

    function buildTitle() {
      var title = 'Probe Dock';

      _.each(Array.prototype.slice.call(arguments), function(part) {
        title += ' > ';

        if (part.length > titleElementLimit) {
          title += part.substr(0, titleElementLimit - 3) + '...';
        } else {
          title += part;
        }
      });

      return title;
    }
  })

  .run(function($rootScope, states) {
    states.onStateChangeSuccess($rootScope, true, function(state, params, resolves) {
      $rootScope.$title = resolves.$title;
    });
  })

;

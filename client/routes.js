angular.module('probedock.routes', [ 'ui.router', 'ui.router.title' ])

  .config(function($stateProvider, $urlRouterProvider) {
    var titleElementLimit = 25;

    $stateProvider

      .state('home', {
        url: '/',
        controller: 'HomePageCtrl',
        templateUrl: '/templates/pages/home/home.template.html',
        resolve: {
          $title: function($stateParams) { return buildTitle($stateParams, 'Home'); }
        }
      })

      .state('home.newOrg', {
        url: 'new',
        resolve: {
          $title: function($stateParams) { return buildTitle($stateParams, 'Home', 'New organization'); }
        }
      })

      .state('error', {
        url: '/error/:type',
        controller: 'ErrorPageCtrl',
        templateUrl: '/templates/pages/error/error.template.html',
        resolve: {
          $title: function($stateParams) { return buildTitle($stateParams, 'Error'); }
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
          $title: function($stateParams) { return buildTitle($stateParams, 'Help', 'Getting started'); }
        }
      })

      .state('newMembership', {
        url: '/new-member?otp',
        controller: 'MemberRegistrationPageCtrl',
        templateUrl: '/templates/pages/member-registration/registration.template.html',
        resolve: {
          $title: function($stateParams) { return buildTitle($stateParams, 'Join organization'); }
        }
      })

      .state('register', {
        url: '/register?otp',
        controller: 'UserRegistrationPageCtrl',
        templateUrl: '/templates/pages/user-registration/registration.template.html',
        resolve: {
          $title: function($stateParams) { return buildTitle($stateParams, 'Register'); }
        }
      })

      .state('confirmRegistration', {
        url: '/confirm-registration?otp',
        controller: 'UserConfirmRegistrationPageCtrl',
        templateUrl: '/templates/pages/user-confirm-registration/confirm.template.html',
        resolve: {
          $title: function($stateParams) { return buildTitle($stateParams, 'Confirm registration'); }
        }
      })

      .state('profile', {
        url: '/profile',
        templateUrl: '/templates/pages/profile/profile.template.html',
        resolve: {
          $title: function($stateParams) { return buildTitle($stateParams, 'Profile'); }
        }
      })

      .state('profile.edit', {
        url: '/edit',
        resolve: {
          $title: function($stateParams) { return buildTitle($stateParams, 'Edit profile'); }
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
          $title: function($stateParams) { return buildTitle($stateParams, 'Users'); }
        }
      })

      .state('admin.management', {
        url: '/management',
        controller: 'ManagementPageCtrl',
        templateUrl: '/templates/pages/management/management.template.html',
        resolve: {
          $title: function($stateParams) { return buildTitle($stateParams, 'Management'); }
        }
      })

      .state('admin.settings', {
        url: '/settings',
        controller: 'AppSettingsPageCtrl',
        templateUrl: '/templates/pages/app-settings/settings.template.html',
        resolve: {
          $title: function($stateParams) { return buildTitle($stateParams, 'Settings'); }
        }
      })

      .state('admin.users.show', {
        url: '/:id',
        resolve: {
          $title: function($stateParams) { return buildTitle($stateParams, 'Users', ':id'); }
        }
      })

      .state('admin.users.show.edit', {
        url: '/edit',
        resolve: {
          $title: function($stateParams) { return buildTitle($stateParams, 'Users', ':id', 'Edit'); }
        }
      })

      .state('org', {
        url: '/:orgName',
        abstract: true,
        template: '<div ui-view />'
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
          $title: function($stateParams) { return buildTitle($stateParams, 'Dashboard'); }
        }
      })

      .state('org.dashboard.default.edit', {
        url: '/edit',
        resolve: {
          $title: function($stateParams) { return buildTitle($stateParams, 'Dashboard', 'Edit organization'); }
        }
      })

      .state('org.dashboard.members', {
        url: '/members',
        controller: 'MemberListPageCtrl',
        templateUrl: '/templates/pages/member-list/list.template.html',
        resolve: {
          $title: function($stateParams) { return buildTitle($stateParams, 'Dashboard', 'Organization members'); }
        }
      })

      .state('org.dashboard.members.new', {
        url: '/new',
        resolve: {
          $title: function($stateParams) { return buildTitle($stateParams, 'Dashboard', 'Organization members', 'Add member'); }
        }
      })

      .state('org.dashboard.members.edit', {
        url: '/:id/edit',
        resolve: {
          $title: function($stateParams) { return buildTitle($stateParams, 'Dashboard', 'Organization members', ':id', 'Edit'); }
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
          $title: function($stateParams) { return buildTitle($stateParams, 'Projects'); }
        }
      })

      .state('org.projects.list.new', {
        url: '/new',
        resolve: {
          $title: function($stateParams) { return buildTitle($stateParams, 'Projects', 'New'); }
        }
      })

      .state('org.projects.list.edit', {
        url: '/edit?id',
        resolve: {
          $title: function($stateParams) { return buildTitle($stateParams, 'Projects', ':id', 'Edit'); }
        }
      })

      .state('org.reports', {
        url: '/reports',
        controller: 'ReportListPageCtrl',
        templateUrl: '/templates/pages/report-list/list.template.html',
        resolve: {
          $title: function($stateParams) { return buildTitle($stateParams, 'Reports'); }
        }
      })

      .state('org.reports.show', {
        url: '/:id',
        resolve: {
          $title: function($stateParams) { return buildTitle($stateParams, 'Reports', ':id'); }
        }
      })

      .state('org.tests', {
        url: '/test',
        abstract: true,
        template: '<div ui-view />'
      })

      .state('org.tests.show', {
        url: '/:testId',
        controller: 'TestDetailsPageCtrl',
        templateUrl: '/templates/pages/test-details/details.template.html',
        resolve: {
          $title: function($stateParams) { return buildTitle($stateParams, 'Tests', ':testId'); }
        }
      })

      // Must be the last route to match any non-reserved word under /:orgName
      .state('org.projects.show', {
        url: '/:projectName',
        controller: 'ProjectDetailsPageCtrl',
        templateUrl: '/templates/pages/project-details/details.template.html',
        resolve: {
          $title: function($stateParams) { return buildTitle($stateParams, 'Projects', ':projectName'); }
        }
      })

      .state('org.projects.show.edit', {
        url: '/edit'
      })
    ;

    $urlRouterProvider.otherwise(function($injector) {
      $injector.get('$state').go('home');
    });

    function buildTitle($stateParams) {
      var title = 'Probe Dock';

      if ($stateParams.orgName) {
        title += ' > ';

        if ($stateParams.orgName.length > titleElementLimit) {
          title += $stateParams.orgName.substr(0, titleElementLimit - 3) + '...'
        } else {
          title += $stateParams.orgName;
        }
      }

      _.each(Array.prototype.slice.call(arguments, 1), function(part) {
        title += ' > ';

        var realPart;
        if (part.charAt(0) == ':') {
          realPart = $stateParams[part.substr(1)];
        } else {
          realPart = part;
        }

        if (realPart.length > titleElementLimit) {
          title += realPart.substr(0, titleElementLimit - 3) + '...';
        } else {
          title += realPart;
        }
      });

      return title;
    }
  })

;

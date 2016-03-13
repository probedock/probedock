// Copyright (c) 2012-2014 Lotaris SA
//
// This file is part of ProbeDock.
//
// ProbeDock is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// ProbeDock is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with ProbeDock.  If not, see <http://www.gnu.org/licenses/>.

angular.module('probedock', [
  // libraries
  'angularMoment',
  'angular-jqcloud',
  'angular-loading-bar',
  'chart.js',
  'duScroll',
  'infinite-scroll',
  'drop-ng',
  'ngClipboard',
  'ngSanitize',
  'ngAnimate',
  'smart-table',
  'truncate',
  'ui.gravatar',
  'ui.bootstrap',
  'ui.select',
  // services
  'probedock.auth',
  'probedock.errors',
  'probedock.orgs',
  'probedock.profile',
  // pages
  'probedock.layout',
  'probedock.appSettingsPage',
  'probedock.dashboardPage',
  'probedock.errorPage',
  'probedock.gettingStartedPage',
  'probedock.homePage',
  'probedock.memberListPage',
  'probedock.memberRegistrationPage',
  'probedock.permalinksPage',
  'probedock.profilePage',
  'probedock.projectDetailsPage',
  'probedock.projectListPage',
  'probedock.reportDetailsPage',
  'probedock.reportListPage',
  'probedock.testDetailsPage',
  'probedock.userListPage',
  'probedock.userRegistrationPage',
  'probedock.userConfirmRegistrationPage',
  // widgets
  'probedock.orgMemberDetailsWidget',
  'probedock.projectDetailsWidget',
  'probedock.projectHealthWidget',
  'probedock.recentActivityWidget',
  'probedock.tagCloudWidget',
  'probedock.testCategoriesBarWidget',
  'probedock.testContributionsWidget',
  'probedock.testExecutionTimeWidget',
  'probedock.testingActivityWidget',
  'probedock.testKeyGeneratorWidget',
  'probedock.testPayloadDropzoneWidget',
  'probedock.testResultsWidget',
  'probedock.testSuiteSizeWidget',
  'probedock.userDetailsWidget',
  // components
  'probedock.categorySelect',
  'probedock.dataLabels',
  'probedock.helpButton',
  'probedock.projectSelect',
  'probedock.projectVersionSelect',
  'probedock.repoIcon',
  'probedock.reportDataLabels',
  'probedock.reportHealthBar',
  'probedock.selectOnClick',
  'probedock.testStatusIcon',
  'probedock.userAvatar',
  'probedock.userSelect',
  // filters
  'probedock.formatDurationFilter',
  'probedock.orgNameFilter',
  'probedock.projectNameFilter',
  // validations
  'probedock.confirmationForValidation',
  'probedock.uniqueOrgNameValidation',
  'probedock.uniqueProjectNameValidation',
  'probedock.uniqueUserEmailValidation',
  'probedock.uniqueUserNameValidation',
  // routes
  'probedock.routes'
])

  // version 0.1.24
  .constant('version', '0.1.0')
  .constant('environment', 'development')
  .constant('zeroClipboardFlash', '/vendor/flash/zero-clipboard.swf')

  // enable debug log unless in production
  .config(function(environment, $logProvider) {
    $logProvider.debugEnabled(environment !== 'production');
  })

  .config(function(ngClipProvider, zeroClipboardFlash) {
    ngClipProvider.setPath(zeroClipboardFlash);
  })

;
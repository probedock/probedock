# Changelog

## v2.1.1 - January 15, 2014

* Page URLs no longer include the locale.

## v2.1.0 - January 14, 2014

* **NEW:** Test page permalinks accessible from each test page.

* The URL for the page describing a test has changed; it now also contains the project API identifier.

* Maintenance mode controllable from settings page (administrators only).

* Ugprade to Rails 4.0.2 and Bootstrap 3.

* The `secret_token.rb` initializer was replaced by the `app_secrets.rb` initializer. See the [deployment documentation](doc/rox/deploy.md).

* Fixed sorting bug on all tables.

* Fixed test key generator bug where keys would not be displayed until the page was reloaded

## v2.0.0 - December 23, 2013

* **NEW:** Projects must now be created in ROX Center before test results can be submitted

* **NEW:** New test analytics; home page widget tracks the evolution of tests by day/week/month

* **NEW:** Hypermedia API with integrated documentation accessible from the menu

* **NEW:** LDAP or password authentication are supported with [devise](https://github.com/plataformatec/devise) (see `config/rox.yml`)

* **NEW:** Administrators can create, deactivate and modify users

* Project version is shown in test run report results

## v1.0.4 - May 24, 2013

* **NEW:** Uncategorized tests can be listed

* **NEW:** Report card tooltips show the test key, duration and result in addition to the name

* **NEW:** Tag cloud on home page only shows 50 most used tags (configurable), with link to full tag cloud

* **NEW:** The number of days before tests are marked as outdated can be configured in the settings

* Fixed unsecure warnings by downloading gravatars over HTTPS in production

* Numbers in *Metrics* page and user info pages are formatted with number separators

* Additional links to other tools are now separated from the brand link

* Test runs table shows run group (e.g. Nightly)

* Fixed a report bug where a result's details could not be filtered out after being shown manually by clicking on the card

* Fixed a report bug where the next run button would remain grayed out even after a new run was received in the same group

* Fixed a bug in the activity listing where the order would get changed after checking for updates in the background

* Fixed a bug where deprecated tests would be counted in the number of tests on the home page

* Fixed test run status to be 99% instead of 100% when over 99.5 but not 100.

### API

* **NEW:** Tag cloud can be retrieved with a max size: `/api/v1/tags/cloud?size=10`

* **NEW:** Test data (`/api/v1/status/tests`) includes the `outdated_days` property which indicates the number of days before tests are marked as outdated without activity

* The activity listing is sorted: technical users are first, then users who have run tests, then those who have never run tests. Technical users and users who have run tests are further sorted with those who have most recently run tests at the top. Users who have not run any tests are sorted alphabetically.

* Fixed a bug where sending duplicate tags or tickets in a test or payload would cause database constraints to fail. Duplicate tags are now ignored. Note that tags are case-insensitive: the **unit** and **Unit** tags are considered the same; the first one sent will be used.

### Known Issues

* Deprecating a test does not decrease the number of tests in the metrics page

* Changing the category or project of a test only increases the number of tests in the new category or project, but does not decrease it in the old

## v1.0.3 - April 3, 2013

* **NEW:** Home page links to jump to the latest test run in a group (e.g. Nightly)

* **NEW:** Home page links to jump to the latest tests of the 5 projects with the most recently created tests

* **NEW:** Administrator can add links to other tools (e.g. bug tracker) which are accessible from the brand link

* **NEW:** Test breakdown pie charts by author, project and category in *Metrics* page; test metrics can additionally be filtered by project and category

* Number of failing tests in activity listing is now a link to list the corresponding tests

* Test status tooltip in test tables with more information (breaker/runner, link to test run)

* Last 50 test run reports are now cached (configurable), older reports will be loaded asynchronously

* Test run reports have more links for easier navigation

* All tables now show a loading icon while downloading data

### API

* **BREAKING!** Payload test result message is now limited to 65535 bytes instead of 65535 characters

* **BREAKING!** API interprets test payload as UTF-8

### Upgrade

* `cache:deploy` rake task must be run instead of `cache:clear`

### Known Issues

* It is not possible to list uncategorized tests

## v1.0.2 - March 6, 2013

* **NEW:** Test run report results can now be filtered by name, key, tags or status

* **NEW:** Red Alert badge: made an all-red test run with at least 3 tests

* Activity listing only shows the latest 5 badges for each user instead of all

* Test run report data loads asynchronously to avoid freezing the UI

* Test run report summary durations now in short format (milliseconds hidden if over one second)

* Runner avatar in test report

### API

* `api.ENVIRONMENT.log` file rotated over 1MB (3 old copies are kept)

* API only answers in JSON

* API error messages now indicate erroneous data

### Upgrade

* **BREAKING!** Removed `/rox` path prefix in production environment

* Removed badge category from database (known from badge class)

* Updated gems (no major changes)

## v1.0.1 - March 4, 2013

* Fixed API log silencing (`/api/v*/activity`, `/api/v*/payload` and `/api/v*/status` only log warnings and errors, other paths log info also)

## v1.0.0 - March 4, 2013

* First stable version

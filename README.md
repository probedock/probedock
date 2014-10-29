# ROX Center

**Test tracking and analysis tool by [Lotaris](http://www.lotaris.com).**

ROX Center tracks the tests in your projects to show you the evolution of your test coverage and analyze the health of your projects.

It has two main components: the ROX Center server and ROX clients.
ROX clients run your tests and upload the results to your ROX Center server for analysis.
The ROX Center server generates test run reports and day-to-day metrics on your tests.

These are the existing ROX clients:

* [RSpec client](https://github.com/lotaris/rox-client-rspec)
* [Karma client](https://github.com/lotaris/rox-client-karma)
* [Jasmine (grunt) client](https://github.com/lotaris/rox-client-grunt-jasmine)
* [Jasmine (grunt-contrib-jasmine) client](https://github.com/lotaris/rox-client-grunt-contrib-jasmine)
* [PHPUnit client](https://github.com/lotaris/rox-client-phpunit)
* [XCTest client](https://github.com/lotaris/rox-client-xctest)

Check out the [client integration guide](https://github.com/lotaris/rox-client) for more information on how to use these clients.
It also contains links to client libraries that provide utilities to develop new clients, as well as a list of the new clients under development.

## Requirements

* Ruby 1.9.3
* MySQL 5.5 or higher (or PostgreSQL 9 or higher)
* Redis 2.6.12 or higher

## Installation

See [deploy.md](doc/deploy.md).

## Usage

This quick tutorial explains how to track your project's tests with ROX Center.

To register as a new user, click the `Register` button in the login form and submit the registration form.
Once you're logged in, you will need to add your project to ROX Center.

In the `Projects` page, click `Add a project`, fill and submit the form.
ROX Center can now analyze test results for this project.

Back in the project list, take a note of the API identifier for your project.
You will need this for the client configuration.
Also go to your account page (`You`); you will see that an API key has been generated for you.
Take a note of its ID and shared secret.

Follow the setup instructions from the [client integration guide](https://github.com/lotaris/rox-client#setup-procedure).

Once your client is set up, run your tests and the data should appear in ROX Center!

## Contributing

* [Fork](https://help.github.com/articles/fork-a-repo)
* Create a topic branch - `git checkout -b feature`
* Push to your branch - `git push origin feature`
* Create a [pull request](http://help.github.com/pull-requests/) from your branch

Please add a changelog entry with your name for new features and bug fixes.

## License

ROX Center is licensed under the [GNU General Public License v3](http://www.gnu.org/licenses/gpl.html).
See [LICENSE.txt](LICENSE.txt) for the full license.

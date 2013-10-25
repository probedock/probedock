# ROX Center

**Test tracking and analysis tool by [Lotaris](http://www.lotaris.com).**

ROX Center tracks the tests in your projects to show you the evolution of your test coverage and analyze the health of your projects.

It has two main components: the ROX Center server and ROX clients.
ROX clients run your tests and upload the results to your ROX Center server for analysis.
The ROX Center server generates test run reports and day-to-day metrics on your tests.

Currently, there is one ROX client:

* [RSpec client](https://github.com/lotaris/rox-client-rspec)

Clients for other testing frameworks are under development:

* JUnit
* Jasmine

## Requirements

* Ruby 1.9.3
* MySQL 5.5
* Redis 2

## Installation

See [deploy.md](doc/rox/deploy.md).

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

Follow the setup instructions from the [RSpec client](https://github.com/lotaris/rox-client-rspec).

Once your client is set up, run your tests and the data should appear in ROX Center!

## Contributing

* [Fork](https://help.github.com/articles/fork-a-repo)
* Create a topic branch - `git checkout -b my_feature`
* Push to your branch - `git push origin my_feature`
* Create a [pull request](http://help.github.com/pull-requests/) from your branch

Please add a changelog entry with your name for new features and bug fixes.

## License

ROX Center is licensed under the [GNU General Public License v3](http://www.gnu.org/licenses/gpl.html).

    Copyright (c) 2012-2013 Lotaris SA

    ROX Center is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    ROX Center is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with ROX Center.  If not, see <http://www.gnu.org/licenses/>.

See `LICENSE.txt` for the full license.

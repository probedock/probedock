# Probe Dock

**Test tracking and analysis tool.**

[![Build Status](https://secure.travis-ci.org/probedock/probedock.svg)](http://travis-ci.org/probedock/probedock)
[![License](https://img.shields.io/badge/license-GPL--3.0-blue.svg)](LICENSE.txt)
[![Waffle Board](https://img.shields.io/badge/waffle-board-blue.svg)](https://waffle.io/probedock/probedock)

Probe Dock tracks the tests in your projects to show you the evolution of your test coverage and analyze the health of your projects.

It has two main components: the Probe Dock server and probes.
Probes hook into your favorite test framework and publish the test results to Probe Dock for analysis.
Probe Dock generates test run reports and day-to-day metrics on your tests.

[Check out our website](http://probedock.io) for more information about how to get started and news.

Head over to the [Probe Dock probes repository](https://github.com/probedock/probedock-probes) to find documentation about specific probes and how to configure them.

## Requirements

**Docker installation:**

* Docker 1.6 or higher

**Classic installation:**

* Ruby 2.2
* Postgresql 9 or higher
* Redis 2.6.12 or higher

## Contributing

* [Fork](https://help.github.com/articles/fork-a-repo)
* Create a topic branch - `git checkout -b feature`
* Push to your branch - `git push origin feature`
* Create a [pull request](http://help.github.com/pull-requests/) from your branch

Please add a changelog entry with your name for new features and bug fixes.

## License

Probe Dock is licensed under the [GNU General Public License v3](http://www.gnu.org/licenses/gpl.html).
See [LICENSE.txt](LICENSE.txt) for the full license.

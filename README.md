[![Stories in Ready](https://badge.waffle.io/probedock/probedock.png?label=ready&title=Ready)](https://waffle.io/probedock/probedock)
# ProbeDock

**Test tracking and analysis tool.**

[![License](https://img.shields.io/github/license/probedock/probedock.svg)](LICENSE.txt)

ProbeDock tracks the tests in your projects to show you the evolution of your test coverage and analyze the health of your projects.

It has two main components: the ProbeDock server and clients.
Clients hook into your favorite test framework and publish the test results to ProbeDock for analysis.
ProbeDock generates test run reports and day-to-day metrics on your tests.

Head over to the [ProbeDock clients repository](https://github.com/probedock/probedock-probes) to find out which clients are available.

## Requirements

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

ProbeDock is licensed under the [GNU General Public License v3](http://www.gnu.org/licenses/gpl.html).
See [LICENSE.txt](LICENSE.txt) for the full license.

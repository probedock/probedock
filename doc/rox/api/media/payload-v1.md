# vnd.lotaris.rox.payload.v1+json

A compact representation of test runs and test results in [JSON](http://www.json.org).

This format minimizes the size of the payload at the expense of readability.
Provided client libraries can generate this format.

## Example

This is a sample payload with all keys and values filled out. Read on for more detailed documentation.

```js
{
  "u": "f47ac10b-58cc",    // Test run unique identifier (defined by you)
  "g": "nightly",          // Test run group (defined by you)
  "d": 3600000,            // Duration in milliseconds of the test run
  "r": [                   // Results by project
    {
      "j": "project12345",     // ROX Project API identifier
      "v": "1.0.2",            // Project version
      "t": [                   // List of test results
        {
          "k": "key123456789"  // ROX test key
          "n": "Test 1",       // Test name
          "p": true,           // Passed (whether the test was successful)
          "d": 500,            // Duration in milliseconds
          "f": 1,              // Optional flags (see ROX flags)
          "m": "It works!",    // Optional detail message
          "c": "soapui",       // Optional category
          "g": [               // Optional list of tags
            "integration",
            "performance"
          ],
          "t": [               // Optional list of tickets/issues
            "#152",
            "#567"
          ],
          "a": {               // Optional data map (defined by you)
            "sql-nb-queries": 4,
            "custom": "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
          }
        }
      ]
    }
  ]
}
```

## Payload Object

A payload represents a test run with test results.

```js
{
  "u": "f47ac10b-58cc",    // Test run unique identifier (defined by you)
  "g": "nightly",          // Test run group (defined by you)
  "d": 3600000,            // Duration in milliseconds of the test run
  "r": [                   // Results by project
  ]
}
```

* `u` - test run **u**nique identifier - `[optional]` `string` `1-255 chars`

  A user-defined UID for the test run. This is optional but useful if you need to
  send a test run's results to ROX Center in multiple API calls. You should reuse
  the same test run UID so that ROX Center knows it's the same test run.

* `g` - test run **g**roup - `[optional]` `string` `1-255 chars`

  A user-defined key to group test runs together.
  For example, to follow the evolution of nightly builds,
  you might use **nightly** as the group key.
  ROX Center will then be able to group all test runs with this key together for analysis.

* `d` - **d**uration - `number` `0+`

  The duration of the entire test run in milliseconds.

* `r` - test **r**uns - `array`

  An array of one or more [project results objects](#project-results-object).

## Project Results Object

A group of results for a project.
If you have results for several projects in the test run,
you will need several of these results objects.

```js
{
  "j": "project12345",   // ROX Project API identifier
  "v": "1.0.2",          // Project version
  "t": [                 // Test results
  ]
}
```

* `j` - **p**roject - `ROX Project API ID`

  The API identifier of the project containing the tests.

* `v` - **v**ersion - `string` `1-255 chars`

  The version of the project.

* `t` - **t**est results - `array`

  An array of one or more [test result objects](#test-result-object).

## Test Result Object

A test result describes a test and the result of running that test.

```js
{
  "k": "key123456789", // ROX Test key
  "n": "Test 1",       // Test name
  "p": true,           // Passed (true if the test was successful)
  "d": 500,            // Duration in milliseconds
  "f": 1,              // Optional flags (see ROX flags)
  "m": "It works!",    // Optional detail message
  "c": "soapui",       // Optional category
  "g": [               // Optional list of tags
    "integration",
    "performance"
  ],
  "t": [               // Optional list of tickets/issues
    "#152",
    "#567"
  ],
  "a": {               // Optional data map (defined by you)
    "sql-nb-queries": "4",
    "custom": "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
  }
}
```

* `k` - **k**ey - `string` `ROX Test Key`

  The key identifying the test.

* `n` - **n**ame - `[optional]` `string` `1-255 chars`

  The human-readable name of the test.
  Can be ommitted for an existing test that already has a name.

  No transformation is applied on the name.
  It is the responsibility of the client to format it in a readable manner.

* `p` - **p**assed - `boolean`

  Whether the test passed or not.

* `d` - **d**uration - `number` `0+`

  The time it took to run this particular test in milliseconds

* `f` - **f**lags - `[optional]` `bitmask`

  Flags that modify the behavior of tests.
  See [test flags](#test-flags).

* `m` - **m**essage - `[optional]` `string` `1-65535b`

  A message describing the result of the test.
  This is typically only set for tests that did not pass to describe the error.
  Note that the maximum length is 65535 bytes.

* `c` - **c**ategory - `[optional]` `string` `1-255`

  User-defined category.
  Example: categorize tests by framework (JUnit, Selenium, RSpec, Jasmine, etc).
  Send `null` to remove a previously set category.

* `g` - ta**g**s - `[optional]` `array`

  User-defined tags.
  Tags can be used to filter tests and from the tag cloud.
  
  This property is an array of tag names.
  Each tag name must be 1-50 characters long and contain only alphanumeric characters, hyphens and underscores.
  Send an empty array to remove previously defined tags.

* `t` - **t**ickets - `[optional]` `array`

  List of issue tracking tickets.
  A URL pattern can be defined to jump directly to the issue tracker from tests.

  This property is an array of ticket names.
  Each ticket name must be 1-255 characters long.
  Send an empty array to remove previously defined tickets.

* `a` - custom d**a**ta - `[optional]` `object`

  Arbitrary data that can be attached to tests.
  Note that the data concerns the test, not the test result.

  This property is a key-value data map.
  Keys must be 1-50 characters long.
  Values must be strings no longer than 255 characters (and may be blank).

## Test Flags

Flags can modify the behavior of tests.
They are serialized as a bitmask.

To compute the flags value for a test, perform a bitwise OR (`|` in most languages) of the masks for the flags you want.

* `inactive` - `mask: 1`

  Mark a test as inactive.
  Inactive tests will not be counted as failing, and inactive results will not increase

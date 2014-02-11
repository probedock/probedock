# API Root Resource

The root of the API provides links to all other resources directly or indirectly.
It is the only resource with a documented URI and must always be your starting point:

    https://rox.example.com/api

## Representation

### Properties

* `appVersion` - `[read-only]` `semantic version`

  The version of ROX Center which follows [Semantic Versioning Guidelines](http://semver.org).
  This is **not** the version of the API.

### Links

* `v1:projects`

  [Projects resource](/doc/api/res/projects) to manage projects.

* `v1:test-keys`

  [Test keys resource](/doc/api/res/test-keys) to request and release test keys.

* `v1:test-payloads`

  [Test payloads resource](/doc/api/res/test-payloads) to submit payloads of test results.

* `help`

  [Documentation of the API](/doc/api) (accept `text/x-markdown` or `text/html`).

* `version-history`

  [Changelog](/doc/changelog) (accept `text/x-markdown` or `text/html`).

### Example

```json
{
  "appVersion": "2.0.0",
  "_links": {
    "self": {
      "href": "https://rox.example.com/uri",
      "title": "API root"
    },
    "help": {
      "href": "https://rox.example.com/uri",
      "type": "text/x-markdown",
      "title": "API documentation"
    },
    "version-history": {
      "href": "https://rox.example.com/uri",
      "type": "text/x-markdown",
      "title": "Changelog"
    },
    "v1:projects": {
      "href": "https://rox.example.com/uri",
      "title": "Projects"
    },
    "v1:test-keys": {
      "href": "https://rox.example.com/uri",
      "title": "Test keys"
    },
    "v1:test-kayloads": {
      "href": "https://rox.example.com/uri",
      "type": "application/vnd.lotaris.rox.payload.v1+json",
      "title": "Submission of test payloads"
    },
    "curies": [
      {
        "href": "https://rox.example.com/uri/{rel}",
        "name": "v1",
        "templated": true
      }
    ]
  }
}
```

## GET

Returns a representation of the API root.

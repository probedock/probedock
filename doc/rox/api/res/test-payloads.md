# API Test Payloads Resource

The URI of this resource can be found in the `v1:test-payloads` link of the [root resource](/doc/api/res/root).

## POST (submit a payload)

Validates and stores a payload of test results for processing.
The request should have a content type of [vnd.lotaris.rox.payload.v1+json](/doc/api/media/payload-v1).

### Responses

* `HTTP 202 Accepted` - empty response

  The payload is valid and has been queued for processing.
  This process is asynchronous.
  The response body is currently empty but may link to a resource indicating the processing status in the future.

* `HTTP 400 Bad Request` - [application/vnd.lotaris.rox.errors+json](/doc/api/media/errors)

  The payload is syntaxically or semantically invalid.
  The response contains a description of the error(s).
  Possible errors are listed below.

### Errors

Also see [generic errors](/doc/api/media/errors#generic-errors).

* `forbiddenTestRunUid`

  The `u` property of the test run is the UID of an existing test run that was created by another ROX user.

* `duplicateProject`

  Several results object have the same `j` property.

* `unknownTestKey`

  The `k` property of a test contains an unknown test key.

* `duplicateTestKey`

  The `k` property of a test key has the same value for multiple tests in the same project.
  If the test run has an UID, previously submitted tests are also checked.

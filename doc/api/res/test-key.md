# Test Key Resource

A test key is the identifier of a test in a ROX Center project.

There is actually no test key resource at this time, but this page documents the representation of test keys.
Use the [test keys resource](/doc/api/res/test-keys) for test key management.

## Representation

### Properties

* `projectApiId` - `string`

  The identifier of the project containing the test.

* `value` - `[read-only]` `string`

  The value of the key.

* `free` - `[read-only]` `boolean`

  If true, it means that the ROX Center instance has not yet received any test results for that key,
  meaning that the key is not yet linked to any test data.

* `createdAt` - `[read-only]` `unix timestamp`

  The time at which the test key was generated in ROX Center.

### Example

```json
{
  "value": "1c846fb4ee9b",
  "projectApiId": "d1c5d12e877b",
  "free": false,
  "createdAt": 1347629477000
}
```

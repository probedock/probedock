# vnd.lotaris.rox.errors+json

An extensible representation to describe syntax and semantic errors in [JSON](http://www.json.org).

## Example

```json
{
  "errors": [
    {
      "message": "Oops, that didn't work"
    },
    {
      "message": "Invalid JSON",
      "name": "json_invalid"
    },
    {
      "message": "Test run must be an object, got array",
      "name": "payload_invalid",
      "path": "/r/0"
    }
  ]
}
```

## Format

### Root Object

```json
{
  "errors": [
    // Error objects...
  ]
}
```

* `errors` - `array`

  A list of errors.
  This is always a list even when there is only one error.

### Error Object

```json
{
  "message": "Payload must be an object, got array",
  "name": "payload_invalid",
  "path": "/a/b/c"
}
```

* `message` - `string`

  Human-readable message describing the error.

* `name` - `[optional]` `token`

  Generic or resource-specific token identifying the error.
  Refer to each resource's documentation and the [list below](#generic-errors) for possible errors.

* `path` - `[optional]` `JSON pointer`

  [RFC 6901 JSON pointer](http://tools.ietf.org/html/rfc6901) to the property that caused the error.

## Generic Errors

The errors listed here can be returned by any resource of the API.

### Request Errors

* `badEncoding`

  The request body is not UTF-8 and cannot be converted to UTF-8.

* `emptyRequest`

  The request body is empty.

* `invalidJson`

  The request body is not valid JSON.

### Format Errors

An error of this type indicates that a key or value in the submitted JSON is invalid (wrong type or format).
The `path` property of the error indicates the relevant JSON key.
Refer to the resource documentation for type and format requirements.

* `missingKey`

  A required key is missing in a JSON object.

* `keyTooLong`

  The length of a key exceeds the documented maximum.
  The maximum length can be defined either in characters or bytes (UTF-8).

* `invalidValue`

  A value is of the wrong type (e.g. a number when a string is expected).

* `blankValue`

  A required or optional value is blank (empty or whitespace string).
  Optional values cannot be blank unless specified otherwise.

* `valueTooLong`

  The length of the value exceeds the documented maximum.
  For strings, the maximum length can be defined either in characters or bytes (UTF-8).

* `emptyArray`

  An array with required elements is empty.

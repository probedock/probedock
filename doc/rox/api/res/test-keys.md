# Test Keys Resource

Test key management resource.

The URI of this resource can be found in the `v1:test-keys` link of the [root resource](/doc/api/res/root).

## Representation

See [listings](/doc/api/listings) for properties.

### Embedded resources

* `v1:test-keys`

  A list of test keys.
  See the [test key representation](/doc/api/res/test-key#representation).

### Example

```json
{
  "total": 26,
  "_links": {
    "curies": [
      {
        "href": "https://rox.example.com/uri/{rel}",
        "name": "v1",
        "templated": true
      }
    ],
    "self": {
      "href": "https://rox.example.com/uri"
    }
  },
  "_embedded": {
    "v1:test-keys": [
      {
        "value": "1c846fb4ee9b",
        "projectApiId": "d1c5d12e877b",
        "free": false,
        "createdAt": 1347629477000
      },
      {
        "value": "843a856137f9",
        "projectApiId": "4f9fc8cdad66",
        "free": false,
        "createdAt": 1347629723000
      }
    ]
  }
}
```

## GET (list test keys or search for a key)

Returns a listing page of test keys belonging to the authenticated user.

### Parameters

See [listings](/doc/api/listings) for generic parameters.

* `projectApiId` - `[optional]` `string`

  Project identifier to list only keys for a given project.

* `free` - `[optional]` `boolean`

  If specified, only free or unfree keys will be listed.

## POST (create one or multiple test keys)

The request body should be the [representation of a test key](/doc/api/res/test-key#representation).
Returns a listing page with the created test keys.

### Parameters

* `n` - `[optional]` `integer: 1+`

  The number of test keys to generate.
  Defaults to 1 if unspecified.

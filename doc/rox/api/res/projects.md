# Projects Resource

Project management resource.

The URI of this resource can be found in the `v1:projects` link of the [root resource](/doc/api/res/root).

## Representation

See [listings](/doc/api/listings) for properties.

### Embedded resources

* `v1:projects`

  A list of projects.
  See the [project representation](/doc/api/res/project#representation).

### Example

```json
{
  "total": 25,
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
    "v1:projects": [
      {
        "name": "A project",
        "urlToken": "project1",
        "apiId": "04febff55f62",
        "activeTestsCount": 110,
        "deprecatedTestsCount": 1,
        "createdAt": 1370436644000,
        "_links": {
          "self": {
            "href": "https://rox.example.com/uri"
          }
        }
      },
      {
        "name": "Another project",
        "urlToken": "project2",
        "apiId": "77886b441c32",
        "activeTestsCount": 9,
        "deprecatedTestsCount": 0,
        "createdAt": 1371136177000,
        "_links": {
          "self": {
            "href": "https://rox.example.com/uri"
          }
        }
      }
    ]
  }
}
```

## GET (list projects or search for a project)

Returns a listing page of projects.

See [listings](/doc/api/listings) for parameters.

## POST (create a project)

The request body should be the [representation of a project](/doc/api/res/project#representation).
Returns a representation of the created project.

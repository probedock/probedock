# Project Resource

A project is an application or component that has a test suite whose results will be sent to ROX Center.

## Representation

### Properties

* `name` - `string` `1-255 chars`

  The human-readable name of the project.

* `urlToken` - `string: /[a-z0-9\—\-]+/i` `1-25 chars`

  The name of the project for URL construction.
  For example, a project with the URL token `a_project` might be accessible at `https://rox.example.com/projects/a_project`.

* `apiId` - `[read-only]` `string`

  A unique identifier of the project within the ROX Center instance.
  It is randomly generated at creation.

* `activeTestsCount` - `[read-only]` `integer`

  The number of non-deprecated tests in the project.

* `deprecatedTestsCount` - `[read-only]` `integer`

  The number of deprecated tests in the project.

* `createdAt` - `[read-only]` `unix timestamp`

  The time at which the project was created in ROX Center.

### Example

```json
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
}
```

## GET (retrieve project information)

Returns a representation of the project.

## PUT (update a project)

The request body should be the representation of a project.
Returns a representation of the updated project.

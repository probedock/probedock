# API Listings

Most list resources in the API (e.g. [projects](/doc/api/res/projects), [test keys](/doc/api/res/test-keys)) have common behaviors and parameters.

## Representation

### Properties

* `total`

  Indicates the total number of records (not just in the current page).
  When searching, this corresponds to the total number of records that match the query.

* `page` `[optional]`

  The page that was returned.
  This is usually only included if it differs from the requested page (e.g. you get page 1 when you request a page that doesn't exist).

## GET (list or search)

### Parameters

* `pageSize` - `[optional]` `integer: 1+`

  The number of records per page.
  Defaults to 10 if unspecified or under 1.

* `page` - `[optional]` `integer: 1+`

  Which page of records to fetch (starts at 1).
  Defaults to 1 if unspecified or outside the range of available pages.

* `quickSearch` - `[optional]` `string`

  A value to filter records by.
  What properties are used to filter is defined by each resource.

* `sort[]` - `[optional]` `array`

  A list of sorting criteria by decreasing priority.
  Each criterion should be an attribute name with a sort direction, e.g. `name asc` or `createdAt desc`.

  For example, to sort by name and descending creation date, the query parameters might be `?sort%5B%5D=name+asc&sort%5B%5D=createdAt+desc`.

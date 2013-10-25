# API Documentation

## Basics

All API access is over HTTPS from `https://rox.example.com/api`, where `rox.example.com` is the domain where ROX Center is deployed.

All data is sent and received as JSON, mostly the JSON variant of [HAL](http://stateless.co/hal_specification.html)
as well as some [custom JSON media types](/doc/api/media).

## Authentication

Authentication to the API is currently done with API keys.

Requests without authentication will receive a response with the status `401 Unauthorized`.

### API Keys

API keys are accessible from your account page.
They are private and should not be shared.

You may request more API keys at your convenience.
Keys can be deactivated and deleted if compromised.

The key identifier and shared secret must be submitted in the `Authorization` header with the custom `RoxApiKey` scheme:

    Authorization: RoxApiKey id="29c78dk3ms8xjqos0f8d" secret="s8fjdicue8a02lxjs84nchh27slym5js8doapx93isjd82l846"

Clients that may not be able to send this header can use the `api_key_id` and `api_key_secret` URL parameters instead:

    curl https://rox.example.com/api?api_key_id=29c78dk3ms8xjqos0f8d&api_key_secret=s8fjdicue8a02lxjs84nchh27slym5js8doapx93isjd82l846

## HAL+JSON

Most resource representations use the JSON variant of [HAL](http://stateless.co/hal_specification.html) which describes hyperlinks in a standard way.
This documentation assumes that you know the [HAL Specification](http://stateless.co/hal_specification.html).

Some resources in the API link to related documentation, like the root resource which links to this page.
Documentation is usually available in the `text/x-markdown` or `text/html` media types.
You may request one of these in the Accept header.

## Hypermedia

ROX Center uses a Hypermedia API that provides links to all resources.
Clients should start at the root of the API and follow link relations to reach the resources they need.
Hardcoded URLs are not supported and may result in client breakage when ROX Center is updated.

Start at the [root of the API](/doc/api/res/root).

Other useful links:

* [Index of relations](/doc/api/rels)
* [Index of media types](/doc/api/media)
* [Index of resources](/doc/api/res)

## Resource Operations

Each resource documentation page indicates:

* Where the URI of the resource can be found.
* What operations can be performed on the resource and the associated HTTP verbs.

Each operation further indicates:

* The purpose or effect of the operation.
* The required content type of the request, if any.

Most operations respond with the status code `200 OK` and the content type `application/hal+json`.
You may assume this is the case if not otherwise specified.
Non-standard operations will indicate possible response codes and content types.

Operations that return `application/hal+json` documents describe available properties, links and embedded resources.

## Client Errors

When making HTTP calls on resources, invalid requests will produce a client error response with an HTTP status code in the `4xx` range.
Refer to the documentation of the resource for possible errors.
Responses may have the following HTTP status codes:

* `400 Bad Request`

  The request is syntaxically or semantically invalid.
  A list of errors describing the issue will be returned in the [vnd.lotaris.rox.errors+json media type](/doc/api/media/errors).

* `401 Unauthorized`

  User credentials are missing or invalid.

* `403 Forbidden`

  The authenticated user does not have access to the resource.

* `404 Not Found`

  The requested resource does not exist.

* `406 Not Acceptable`

  The resource cannot be represented in the media types requested by the client in the Accept header.
  Refer to the documentation of the resource for available media types.

* `415 Unsupported Media Type`

  The request entity is in a media type not supported by the resource.
  Refer to the documentation of the resource for possible media types.

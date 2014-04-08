# Zmey API Documentation

Zmey has a REST API that returns data in JSON format.

## Authentication

Requests are made using HTTP basic authentication over SSL, providing an API
key as the username and a blank password.

## Retrieving an API key for client applications

Client applications can exchange a manager or admin's username and password
for an API key. A GET request can be sent to `/admin/api_keys/retrieve/:name`
where `:name` is the name of the API key belonging to the user. The user's
credentials should be supplied using HTTP basic authentication over SSL.

The API key must be created in advance.

A failed authentication will result in an empty response with 401 status.

A 404 status is returned if an API key matching `:name` is not found.

An example curl request:

`curl example.com/admin/api_keys/retrieve/ios -u ianf@yesl.co.uk:secret`

A successful retrieval will return JSON similar to the example:

```json
{
  "api_key": {
    "id":1,
    "name":"ios",
    "key":"450dfd180007bf5d66af756c6b5b6805",
    "user_id":1,
    "created_at":"2014-04-07T17:22:56.000+01:00",
    "updated_at":"2014-04-07T17:22:56.000+01:00"
  }
}
```

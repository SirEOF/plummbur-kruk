# Plummbur Kruk

A “real fake” HTTP server specially designed to support browsers tests that make HTTP requests.

[![Build Status](https://drone.io/github.com/eee-c/plummbur-kruk/status.png)](https://drone.io/github.com/eee-c/plummbur-kruk/latest)

## Getting Started

You'll need [Dart](http://dartlang.org).

Install this from [pub](http://pub.dartlang.org) as `plummbur_kruk`.

To start the plummbur_kruk server, use the `start.sh` script:

```bash
# Start the test server
packages/plummbur_kruk/start.sh
```

The test server runs on port `31337`.

To stop the server, use the `stop.sh` script:

```bash
# Stop the server
packages/plummbur_kruk/stop.sh
```

## Using with dart:html

A REST-like API is available at `http://localhost:31337/widgets`. The most common REST verbs will work: GET, POST, PUT, DELETE.

When testing browser code, it is not possible to access a running server. The Kruk server can be controlled through a simple client-side API.

To create a record, use:

```dart
static Future<HttpRequest> create(String json)
```

For example:

```dart
  var id;
  setUp(() {
    return Kruk.
      create('{"foo": 42}').
      then((res) {
        id = JSON.parse(res.responseText)['id'];
      });
  });
```

If you would like a one-request alias for `/widgets`, use `Kruk.alias()`:

```dart
static Future<HttpRequest> alias(String old_url, {as: String})
```

To delete all record, use `Kruk.deleteAll()`:

```dart
static Future<HttpRequest> deleteAll()
```

This is especially useful when deleting records in a unittest `tearDown()`:
```dart
  tearDown(()=> Kruk.deleteAll());
```

## As Part of a Test Runner

In a `test_runner.sh` script, be sure to allow `stop.sh` to run _before_ exiting on failure:

```bash
# Start the test server
echo "starting test server"
packages/plummbur_kruk/start.sh

echo "content_shell --dump-render-tree test/index.html"
results=`content_shell --dump-render-tree test/index.html 2>&1`

echo "$results"

# Stop the server
packages/plummbur_kruk/stop.sh

# check to see if DumpRenderTree tests
# fails, since it always returns 0
if [[ "$results" == *"Some tests failed"* ]]; then
    exit 1
fi

if [[ "$results" == *"Exception: "* ]]; then
    exit 1
fi
```

## Address Already in Use

Sometimes it is possible for things to go quite wrong. If the `kruk.pid` file is deleted before the server shuts down, it needs to be stopped manually. The `netstat` command is your friend:

```bash
$ sudo netstat -nlp | grep 31337
tcp        0      0 127.0.0.1:31337         0.0.0.0:*               LISTEN      2879/dart
$ kill 2879
```

## License

This software is licensed under the MIT License. See LICENSE for details.

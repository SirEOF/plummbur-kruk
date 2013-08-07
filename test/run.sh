#!/bin/bash

# TODO: dartanalyzer

###
# Test the server with server tools
echo "Running dart:io tests"
dart test/server_test.dart

###
# Test the server from the browser
echo
echo "Running dart:html tests"

# Start the test server
dart test/dummy_server.dart &
server_pid=$!

# Run the actual tests
for test in 'index'
do
  echo "tests: $test"
  results=`content_shell --dump-render-tree test/$test.html 2>&1`
  echo $results
  echo "$results" | grep CONSOLE

  echo "$results" | grep 'unittest-suite-success' >/dev/null

  echo "$results" | grep -v 'Exception: Some tests failed.' >/dev/null
done

#TODO now need to exit 1 after killing the server...

# Stop the server
kill $server_pid
rm -f test.db test/test.db

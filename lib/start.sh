#!/bin/sh


#####
# Start a Kruk server

pid_file="kruk.pid"

dart --package-root=packages packages/plummbur_kruk/server.dart &
server_pid=$!
echo "$server_pid" > kruk.pid

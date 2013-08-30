#!/bin/sh


#####
# Start a Kruk server

pid_file="kruk.pid"

dart packages/plummbur_kruk/server.dart &
server_pid=$!
echo "$server_pid" > kruk.pid

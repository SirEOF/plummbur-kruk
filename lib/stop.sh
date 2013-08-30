#!/bin/sh

#####
# Kill a running Plummbur Kruk server and to clean up any by-products

pid_file="kruk.pid"

if [ ! -e "$pid_file" ]
then
    echo "Kruk is not running"
    exit
fi

pid=$(cat $pid_file)
kill $pid

packages/plummbur_kruk/clean.sh

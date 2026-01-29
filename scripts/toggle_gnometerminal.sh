#!/usr/bin/bash

# is it running?
pid=`ps -ef | grep 'gnome-terminal' | grep -v grep | awk '{ print $2 }'`
if [ -z "$pid" ]; then
    echo "empty string."
else
    echo "The string is not empty."
fi

#!/bin/bash
# Start Bird & config watcher

set -m

bird -fR &

./reconfig.sh &


fg %1

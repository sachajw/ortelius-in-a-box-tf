#!/bin/bash
set -e

sed -i "s/K8SIPADDR/${BIRD_HOST}/g" /usr/local/include/birdvars.conf

exec "$@"

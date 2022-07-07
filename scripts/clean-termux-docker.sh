#!/bin/sh
set -e -u

: ${CONTAINER_NAME:=termux-$ARCH}
docker kill $CONTAINER_NAME
docker rm $CONTAINER_NAME

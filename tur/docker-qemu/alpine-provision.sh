#!/bin/sh
set -e
setup-alpine
apk update
apk add docker docker-cli-compose
rc-update add docker boot
service docker start
echo "Docker is ready. Test with: docker run hello-world"

#!/bin/bash
##Script to test that docker image runs correctly
[ -z "$1" ] && echo "First argument must be image to run" && exit 1

image="$1"

function cleanup() {
	docker rm -f emu > /dev/null
}

trap cleanup SIGTERM SIGINT

docker run -d --name emu "$1"

timeout 60s bash -c 'while [ "$(docker inspect -f {{.State.Health.Status}} emu)" != "healthy" ]; do sleep 2;	done'

cleanup

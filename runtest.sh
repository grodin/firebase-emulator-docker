#!/bin/bash

set -eo pipefail

##Script to test that docker image runs correctly
[ -z "$1" ] && echo "First argument must be image to run" && exit 1

image="$1"

function cleanup() {
	docker rm -f emu > /dev/null
}

trap cleanup SIGTERM SIGINT

auth_port=9099
firestore_port=8080

docker run \
  --publish "$auth_port":"$auth_port" \
  --publish "$firestore_port":"$firestore_port" \
	--detach \
	--name emu \
	"$image"

function wait_for_emulator() {
  local health
  while [[ "$health" != "healthy" ]]
  do
    sleep 2
    health=$(docker inspect -f '{{.State.Health.Status}}' emu)
    echo "$(date -Iseconds): $health"
  done
}

export -f wait_for_emulator
timeout --foreground 60s bash -c wait_for_emulator

curl localhost:"$auth_port"
curl localhost:"$firestore_port"

cleanup

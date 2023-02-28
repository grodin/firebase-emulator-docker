#!/bin/bash
set -o errexit
set -o nounset
url="http://localhost"
auth_port="${1:-9099}"
firestore_port="${2:-8080}"
curl -fs "$url:${auth_port}" ||  exit 1
curl -fs "$url:${firestore_port}" || exit 2

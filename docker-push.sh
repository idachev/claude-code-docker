#!/bin/bash
[ "$1" = -x ] && shift && set -x
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${DIR}"/igd-utils-lib.sh

TAG=$1

if [[ -z "${TAG}" ]]; then
  TAG=${IGD_UTILS_DOCKER_TAG}
fi

LOCAL_DOCKER_IMG=${IGD_UTILS_DOCKER_IMG}:${TAG}

REMOTE_DOCKER_IMG=${IGD_UTILS_REMOTE_DOCKER_USER}/${IGD_UTILS_DOCKER_IMG}:${TAG}

set -e

docker tag "${LOCAL_DOCKER_IMG}" "${REMOTE_DOCKER_IMG}"

docker push "${REMOTE_DOCKER_IMG}"

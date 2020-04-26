#!/usr/bin/env sh
set -o pipefail

root_dir=$(pwd)

if [ $# -ne 1 ]; then
	echo
	echo "usage: $0 version distribution linux_version"
	exit -1
fi

DOCKER_TAG=$1

IMAGE_NAME=poad/docker-jupyter:${DOCKER_TAG}

export DOCKERFILE_PATH
export DOCKER_TAG
export IMAGE_NAME

echo "${DOCKER_PASSWORD}" | docker login -u "${DOCKER_USERNAME}" --password-stdin

echo "docker push ${IMAGE_NAME}"

docker push ${IMAGE_NAME}

#!/usr/bin/env sh
set -o pipefail

root_dir=$(pwd)

if [ $# -ne 2 ]; then
	echo
	echo "usage: $0 tag directory"
	exit -1
fi

DOCKER_TAG=$1
DIRECTORY=$2
DOCKERFILE_PATH=""

IMAGE_NAME=poad/docker-jupyter:${DOCKER_TAG}

export DOCKERFILE_PATH
export DOCKER_TAG
export IMAGE_NAME

cd "${DIRECTORY}"

sh hooks/build

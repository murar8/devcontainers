#!/usr/bin/env bash

set -e

GITHUB_SHA=$1
GITHUB_REF=$2
GITHUB_REPOSITORY=$3
GITHUB_REPOSITORY_OWNER=$4
BASE_IMAGE=$5
IMAGE=$6

function set-output() {
    output="$2"

    output="${output//'%'/%25}"
    output="${output//$'\n'/%0A}"
    output="${output//$'\r'/%0D}"

    echo "::set-output name=$1::$output"
}

if [[ ! -z $IMAGE ]]; then
    FILE="./containers/$IMAGE/Dockerfile"
else
    FILE="./containers/$BASE_IMAGE/Dockerfile"
fi

set-output "file" "$FILE"

REF=$(echo $GITHUB_REF | sed -s 's/refs\/.\+\///')

if [ $REF == "main" ]; then
    TAG="nightly"
    VERSION="$GITHUB_SHA"
else
    TAG="latest"
    VERSION="$REF"
fi

BASE_TAG="ghcr.io/$GITHUB_REPOSITORY_OWNER/devcontainer-$BASE_IMAGE"

if [[ ! -z $IMAGE ]]; then BASE_TAG=$BASE_TAG-$IMAGE; fi

TAGS="
$BASE_TAG:$TAG
$BASE_TAG:$VERSION
"

set-output "tags" "$TAGS"

LABELS="
org.opencontainers.image.authors=Lorenzo Murarotto <lnzmrr@gmail.com>
org.opencontainers.image.licenses=MIT
org.opencontainers.image.created=$(date --rfc-3339=seconds)
org.opencontainers.image.source=https://github.com/$GITHUB_REPOSITORY
org.opencontainers.image.version=$VERSION"

set-output "labels" "$LABELS"

# if [[ ! -z $IMAGE ]]; then
#     BASE_IMAGE_TYPE=$BASE_IMAGE
#     BASE_IMAGE_TAG=$TAG
# else
#     BASE_IMAGE_TYPE=$BASE_IMAGE
#     BASE_IMAGE_TAG=$TAG
# fi

BUILD_ARGS="BASE_IMAGE_TYPE=$BASE_IMAGE BASE_IMAGE_TAG=$TAG"

set-output "build-args" "$BUILD_ARGS"

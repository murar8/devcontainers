#!/usr/bin/env bash

set -e

function usage() {
  echo
  echo "Build a docker image composed of the provided layers and optionally push it to the supplied registry."
  echo
  echo "usage: $(basename $0) [options]... <build-context> <image-name> <base-image> <layers>..."
  echo
  echo "Positional arguments:"
  echo
  echo "build-context               Working directory where docker will build the images."
  echo "image-name                  Tag name of the output image."
  echo "base-image                  Name of the root image on which the layers will be applied."
  echo "layers                      Paths to the layers to be applied."
  echo
  echo "Named arguments:"
  echo
  echo "--tags                      Space separated list of tags to add to the output image."
  echo "--labels                    Space separated list of labels to add to the output image."
  echo "--push                      Push the images to the registry."
  echo "--cache-name                Name of the cache image."
  echo
}

BUILD_CONTEXT=""
IMAGE_NAME=""
BASE_IMAGE=""
LAYERS=()
TAGS=()
LABELS=()
PUSH=false
CACHE_NAME=""

while (($#)); do
  case $1 in
  --tags)
    while [[ "$#" -ge 2 && "$2" != -* ]]; do
      TAGS+=("$2")
      shift
    done
    ;;
  --labels)
    while [[ "$#" -ge 2 && "$2" != -* ]]; do
      LABELS+=("$2")
      shift
    done
    ;;
  --push)
    PUSH=true
    ;;
  --cache-name)
    if [[ $2 != -* ]]; then
      CACHE_NAME="$2"
      shift
    fi
    ;;
  --) ;;
  -*)
    echo
    echo "Unknown option: $1"
    usage
    exit 1
    ;;
  *)
    POSITIONAL_ARGS+=("$1")
    ;;
  esac
  shift
done

if [ "${#POSITIONAL_ARGS[@]}" -lt 4 ]; then
  echo "Not enough arguments provided."
  exit 1
fi

BUILD_CONTEXT="${POSITIONAL_ARGS[0]}"
BASE_IMAGE="${POSITIONAL_ARGS[1]}"
IMAGE_NAME="${POSITIONAL_ARGS[2]}"
LAYERS="${POSITIONAL_ARGS[@]:3}"

echo
echo "Build context:      $BUILD_CONTEXT"
echo "Image name:         $IMAGE_NAME"
echo "Base image:         $BASE_IMAGE"
echo "Layers:             ${LAYERS[@]}"
echo "Tags:               ${TAGS[@]}"
echo "Labels:             ${LABELS[@]}"
echo "Push to registry:   ${PUSH}"
echo "Cache name:         ${CACHE_NAME}"
echo

push_image() {
  docker push $1 1>/dev/null
}

tag="$BASE_IMAGE"

for layer in ${LAYERS[@]}; do
  file="$BUILD_CONTEXT/$layer/Dockerfile"
  checksum=$(echo -n $tag $layer | sha1sum | head -c 8)
  last_tag="$tag"
  tag="${CACHE_NAME:-$IMAGE_NAME-build}:$checksum"

  echo "Adding layer '$layer' to '$last_tag'."

  args=(
    "$BUILD_CONTEXT" "--file=$file" "--build-arg=BASE_IMAGE=$last_tag" "--tag=$tag" "--cache-from=$tag"
  )

  image_id=$(docker build --quiet ${args[@]})
  echo "Successfully built '$tag'."

  if ! [ -z $CACHE_NAME ]; then
    echo "Pushing '$tag' to the registry."
    push_image "$tag"
  fi

  echo
done

tags=(${TAGS[@]/#/$IMAGE_NAME:})

echo "Adding labels and tags to '$tag'."
image_id=$(echo "FROM $tag" | docker build --quiet - "${LABELS[@]/#/--label=}" "${tags[@]/#/--tag=}")
echo "Successfully built '${tags[0]}'."

if [ $PUSH = true ]; then
  for tag in ${tags[@]}; do
    echo "Pushing '$tag' to registry."
    push_image "$tag"
  done
fi

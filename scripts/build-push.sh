#!/usr/bin/env bash

set -e

export DOCKER_CLI_EXPERIMENTAL=enabled

function usage() {
  echo
  echo "Build a docker image composed of the provided layers"
  echo "and optionally push it along with the cache to the supplied registry."
  echo
  echo "usage: $(basename $0) [arguments]..."
  echo
  echo "Arguments:"
  echo
  echo "--base-image      <required>    Name of the root image on which the layers will be applied."
  echo "--layers          <required>    Layers to be applied."
  echo "--image-name      <required>    Name of the output image."
  echo '--cache-name      $image-name   Name of the intermediate images.'
  echo "--tags            [ latest ]    Space separated list of tags to add to the output image."
  echo "--labels          [ ]           Space separated list of labels to add to the output image."
  echo "--push            false         Push the images to the registry."
  echo
}

function parse_parameter() {
  if [[ "$#" -ge 2 && $2 != -* ]]; then
    echo "$2"
  else
    echo "Argument $1 requires a parameter." >&2
    exit 1
  fi
}

while (($#)); do
  case $1 in
  --base-image)
    BASE_IMAGE="$(parse_parameter $@)"
    shift 2
    ;;
  --image-name)
    IMAGE_NAME="$(parse_parameter $@)"
    shift 2
    ;;
  --cache-name)
    CACHE_NAME="$(parse_parameter $@)"
    shift 2
    ;;
  --layers)
    while [[ "$#" -ge 2 && "$2" != -* ]]; do
      LAYERS+=("$2")
      shift
    done
    shift
    ;;
  --tags)
    while [[ "$#" -ge 2 && "$2" != -* ]]; do
      TAGS+=("$2")
      shift
    done
    shift
    ;;
  --labels)
    while [[ "$#" -ge 2 && "$2" != -* ]]; do
      LABELS+=("$2")
      shift
    done
    shift
    ;;
  --push)
    PUSH=true
    shift
    ;;
  --)
    shift
    ;;
  --* | -*)
    echo
    echo "Unknown option: $1"
    usage
    exit 1
    ;;
  esac
done

function check() {
  if [ -z $1 ]; then
    echo "Missing required argument."
    usage
    exit 1
  fi
}

check $BASE_IMAGE
check $LAYERS
check $IMAGE_NAME

if [ -z $CACHE_NAME ]; then
  CACHE_NAME=$IMAGE_NAME
fi

if [ -z $TAGS ]; then
  TAGS=("latest")
fi

BASE_IMAGE=$(docker buildx imagetools inspect $BASE_IMAGE | grep -Pom1 '(?<=Name:      ).*')
TAGS=(${TAGS[@]/#/$IMAGE_NAME:})
BUILD_CONTEXT=$PWD

echo
echo "Base image:         $BASE_IMAGE"
echo "Layers:             ${LAYERS[@]}"
echo "Image name:         $IMAGE_NAME"
echo "Cache name:         $CACHE_NAME"
echo "Tags:               ${TAGS[@]}"
echo "Labels:             ${LABELS[@]}"
echo "Build context:      $BUILD_CONTEXT"
echo "Push to registry:   ${PUSH:-false}"
echo

if [[ $PUSH == true ]]; then
  BUILDER=$(docker buildx create --driver docker-container --use --driver-opt network=host)
else
  docker buildx use default
fi

tags=("$BASE_IMAGE") # The tags of the parent image.

for layer in ${LAYERS[@]}; do

  file="layers/$layer/Dockerfile"
  base_image="${tags[0]}"
  tags=("$CACHE_NAME:$(echo -n $base_image $layer | sha1sum | head -c 8)")
  if [[ $layer == ${LAYERS[-1]} ]]; then tags+=(${TAGS[@]}); fi

  echo "Adding layer '$layer' to '$base_image'."
  echo

  args=("$BUILD_CONTEXT" "--file=$file" "--build-arg=BASE_IMAGE=$base_image" "--output=type=image")

  if [[ $PUSH == true ]]; then
    args+=("--cache-from=${tags[0]}" "--cache-to=type=inline" "--push")
  fi

  docker buildx build --progress plain "${args[@]}" "${LABELS[@]/#/--label=}" "${tags[@]/#/--tag=}"

  echo
  echo "Successfully built '${tags[0]}'."
  echo
done

docker buildx rm $BUILDER

#!/usr/bin/env bash

set -e

function usage() {
  echo
  echo "Build a docker image composed of the provided layers and push it to the supplied registry."
  echo
  echo "usage: $(basename $0) [arguments]..."
  echo
  echo "Arguments:"
  echo
  echo "--base-image        Required    Name of the root image on which the layers will be applied."
  echo "--image-name        Required    Name of the output image."
  echo "--build-context     Required    Working directory where docker will build the images."
  echo "--layers            Required    Layers to be applied."
  echo "--push              false       Push the image to the registry after building it."
  echo "--cache-repo                    Repository where cache images will be stored."
  echo "--tags              []          Space separated list of tags to add to the output image."
  echo "--labels            []          Space separated list of labels to add to the output image."
  echo
}

PUSH=false

while (($#)); do
  case $1 in
  --build-context)
    if [[ $2 != -* ]]; then
      BUILD_CONTEXT="$2"
      shift
    fi
    shift
    ;;
  --base-image)
    if [[ $2 != -* ]]; then
      BASE_IMAGE="$2"
      shift
    fi
    shift
    ;;
  --image-name)
    if [[ $2 != -* ]]; then
      IMAGE_NAME="$2"
      shift
    fi
    shift
    ;;
  --push)
    PUSH=true
    shift
    ;;
  --cache-repo)
    if [[ $2 != -* ]]; then
      CACHE_REPO="$2"
      shift
    fi
    shift
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

check() {
  if [ -z $1 ]; then
    echo "Missing required argument."
    usage
    exit 1
  fi
}

check $BUILD_CONTEXT
check $BASE_IMAGE
check $IMAGE_NAME
check $LAYERS

echo
echo "Build context:      $BUILD_CONTEXT"
echo "Base image:         $BASE_IMAGE"
echo "Image name:         $IMAGE_NAME"
echo "Layers:             ${LAYERS[@]}"
echo "Push to registry:   $PUSH"
echo "Cache repository:   $CACHE_REPO"
echo "Tags:               ${TAGS[@]}"
echo "Labels:             ${LABELS[@]}"
echo

tags=("$BASE_IMAGE") # The tags of the parent image.

for layer in ${LAYERS[@]}; do

  file="$layer/Dockerfile"

  if ! [ -f $file ]; then
    echo "Dockerfile not found for layer: $layer"
    exit 1
  fi

  last_tag="${tags[0]}"

  if [[ $layer == ${LAYERS[-1]} ]]; then
    tags=(${TAGS[@]/#/$IMAGE_NAME:})
  else
    checksum=$(echo -n $tag $layer | sha1sum | head -c 8)
    tags=("${CACHE_REPO:-$IMAGE_NAME-build}:$checksum")
  fi

  echo "Adding layer '$layer' to '$last_tag'."
  echo

  args=("$BUILD_CONTEXT" "--file=$file" "--build-arg=BASE_IMAGE=$last_tag" "--push")

  if [-n $CACHE_REPO]; then
    args+=("--cache-from=type=registry,ref=${tags[0]}""--cache-to=type=inline")
  fi

  DOCKER_CLI_EXPERIMENTAL=enabled docker buildx build \
    --progress plain \
    "${args[@]}" \
    "${LABELS[@]/#/--label=}" \
    "${tags[@]/#/--tag=}"

  echo
  echo "Successfully built '${tags[0]}'."
  echo
done

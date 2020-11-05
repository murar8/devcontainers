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
  echo "--build-context     Required    Working directory where docker will build the images."
  echo "--base-image        Required    Name of the root image on which the layers will be applied."
  echo "--image-name        Required    Name of the output image."
  echo "--layers            Required    Layers to be applied."
  echo "--cache-repo        Required    Repository name where cache images will be stored."
  echo "--tags              []          Space separated list of tags to add to the output image."
  echo "--labels            []          Space separated list of labels to add to the output image."
  echo
}

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
check $CACHE_REPO

echo
echo "Build context:      $BUILD_CONTEXT"
echo "Base image:         $BASE_IMAGE"
echo "Image name:         $IMAGE_NAME"
echo "Layers:             ${LAYERS[@]}"
echo "Cache repository:   $CACHE_REPO"
echo "Tags:               ${TAGS[@]}"
echo "Labels:             ${LABELS[@]}"
echo

tags=("$BASE_IMAGE")

for layer in ${LAYERS[@]}; do
  file="$layer/Dockerfile"
  last_tag="${tags[0]}"

  if [[ $layer == ${LAYERS[-1]} ]]; then
    tags=(${TAGS[@]/#/$IMAGE_NAME:})
  else
    checksum=$(echo -n $tag $layer | sha1sum | head -c 8)
    tags=("$CACHE_REPO:$checksum")
  fi

  echo "Adding layer '$layer' to '$last_tag'."
  echo

  args=(
    "$BUILD_CONTEXT"
    "--file=$file"
    "--build-arg=BASE_IMAGE=$last_tag"
    "--cache-from=type=registry,ref=${tags[0]}"
    "--cache-to=type=inline"
    "--push"
  )

  DOCKER_CLI_EXPERIMENTAL=enabled docker buildx build \
    --progress plain \
    "${args[@]}" \
    "${LABELS[@]/#/--label=}" \
    "${tags[@]/#/--tag=}"

  echo
  echo "Successfully built '${tags[0]}'."
  echo
done

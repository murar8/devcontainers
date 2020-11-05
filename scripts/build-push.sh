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

while (($#)); do
  case $1 in
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
  --cache-name)
    if [[ $2 != -* ]]; then
      CACHE_NAME="$2"
      shift
    fi
    shift
    ;;
  --)
    shift
    ;;
  -*)
    echo
    echo "Unknown option: $1"
    usage
    exit 1
    shift
    ;;
  *)
    POSITIONAL_ARGS+=("$1")
    shift
    ;;
  esac

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

tag="$BASE_IMAGE"

for layer in ${LAYERS[@]}; do
  file="$BUILD_CONTEXT/$layer/Dockerfile"
  checksum=$(echo -n $tag $layer | sha1sum | head -c 8)
  last_tag="$tag"
  tag="${CACHE_NAME:-$IMAGE_NAME-build}:$checksum"

  echo "Adding layer '$layer' to '$last_tag'."

  args=(
    "$BUILD_CONTEXT"
    "--file=$file"
    "--build-arg=BASE_IMAGE=$last_tag"
    "--tag=$tag"
    "--cache-from=$tag"
  )

  docker build --quiet "${args[@]}" "${LABELS[@]/#/--label=}" 1>/dev/null

  echo "Successfully built '$tag'."

  if ! [ -z $CACHE_NAME ]; then
    echo "Pushing '$tag' to the registry."
    docker push $1 "$tag" 1>/dev/null
  fi

  echo
done

tags=(${TAGS[@]/#/$IMAGE_NAME:})

for ptag in ${tags[@]}; do
  echo "Adding tag '$ptag' to '$tag'."
  docker tag "$tag" "$ptag"
done

echo

if [ $PUSH = true ]; then
  for ptag in ${tags[@]}; do
    echo "Pushing '$ptag' to registry."
    docker push "$ptag" 1>/dev/null
  done
fi

#!/usr/bin/env bash
#
# Build a docker image composed of the provided layers and push it to currently logged in registry.
# Note that push and cache functionality are only available when using buildx.
#
# Arguments:
#
# --image-base    [ Required ]      Name of the base image.
# --image-name    [ Required ]      Name of the resulting image.
# --image-layers  [ Required ]      Comma separated list of layers.
# --image-tags    ""                Comma separated list of tags.
# --image-labels  ""                Comma separated list of labels.
#
# Buildx arguments:
# --use-Buildx    false             Build images with buildx.
# --push          false             Push the images to the registry.
# --cache-from    ""                External cache sources.
# --cache-to      ""                Cache export destinations.
#

set -e

ROOT_PATH="$(readlink -f $(dirname $0)/..)"

LAYERS_PATH="$ROOT_PATH/layers"

for i in "$@"; do
  case $i in
  --image-base=*)
    BASE_IMAGE="${i#*=}"
    shift
    ;;
  --image-name=*)
    IMAGE_NAME="${i#*=}"
    shift
    ;;
  --image-layers=*)
    LAYERS="${i#*=}"
    readarray -td, LAYERS <<<"${i#*=},"
    unset 'LAYERS[-1]'
    shift
    ;;
  --image-tags=*)
    IMAGE_TAGS+=("${i#*=}")
    readarray -td, IMAGE_TAGS <<<"${i#*=},"
    unset 'IMAGE_TAGS[-1]'
    shift
    ;;
  --image-labels=*)
    IMAGE_LABELS+=("${i#*=}")
    readarray -td, IMAGE_LABELS <<<"${i#*=},"
    unset 'IMAGE_LABELS[-1]'
    shift
    ;;
  --use-buildx=*)
    USE_BUILDX="${i#*=}"
    shift
    ;;
  --use-buildx)
    USE_BUILDX="true"
    shift
    ;;
  --push=*)
    PUSH="${i#*=}"
    shift
    ;;
  --push)
    PUSH="true"
    shift
    ;;
  --cache-from=*)
    CACHE_FROM="${i#*=}"
    shift
    ;;
  --cache-to=*)
    CACHE_TO="${i#*=}"
    shift
    ;;
  *)
    echo "Unknown option: ${i}"
    exit 1
    ;;
  esac
done

check() {
  if [ -z $1 ]; then
    echo "Missing required argument."
    exit 1
  fi
}

check $BASE_IMAGE
check $LAYERS
check $IMAGE_NAME

echo
echo "Base image:         $BASE_IMAGE"
echo "Image name:         $IMAGE_NAME"
echo "Layers:             ${LAYERS[@]}"
echo "Image tags:         ${IMAGE_TAGS[@]}"
echo "Image labels:       ${IMAGE_LABELS[@]}"
echo "Use buildx:         ${USE_BUILDX}"
echo "Push to registry:   ${PUSH}"
echo "Cache source:       ${CACHE_FROM}"
echo "Cache destination:  ${CACHE_TO}"

for layer in ${LAYERS[@]}; do
  file="$LAYERS_PATH/$layer.Dockerfile"

  if [ -z $last_tag ]; then
    last_tag=$BASE_IMAGE
  fi

  if [ "$layer" = "${LAYERS[-1]}" ]; then
    # if this is the final image insert the proper tags
    tags=(${IMAGE_TAGS[@]/#/$IMAGE_NAME:})
  else
    # otherwise tag with the hash of the applied layers
    checksum=$(echo -n $last_tag $layer | sha1sum | head -c 8)
    tags=("$IMAGE_NAME-build:$checksum")
  fi

  echo
  echo "Adding layer '$layer' to '$last_tag'."
  echo

  args=(
    "$ROOT_PATH"
    "--file=$file"
    "--build-arg=BASE_IMAGE=$last_tag"
    "${IMAGE_LABELS[@]/#/--label=}"
    "${tags[@]/#/--tag=}"
  )

  if [ "$USE_BUILDX" = true ]; then
    build_cmd="docker buildx build"
    args+=(
      "--cache-from=$CACHE_FROM"
      "--cache-to=$CACHE_TO"
      "--push=$PUSH"
    )
  else
    build_cmd="docker build"
  fi

  $build_cmd "${args[@]}"

  last_tag=${tags[0]}
done

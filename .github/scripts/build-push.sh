#!/usr/bin/env bash
#
# Build a docker image composed of the provided layers and push it to currently logged in registry.
#
# Arguments:
#
# --image-base    *     Name of the base image.
# --image-name    *     Name of the resulting image.
# --image-layers  *     Comma separated list of layers.
# --image-tags          Comma separated list of tags.
# --image-labels        Comma separated list of labels.
#
# --cache-from          External cache sources.
# --cache-to            Cache export destinations.
#

set -e

ROOT_DIR="$(readlink -f $(dirname $0)/../..)"
LAYERS_PATH="$ROOT_DIR/layers"

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
echo "Base image:   $BASE_IMAGE"
echo "Image name:   $IMAGE_NAME"
echo "Layers:       ${LAYERS[@]}"
echo "Image tags:   ${IMAGE_TAGS[@]}"
echo "Image labels: ${IMAGE_LABELS[@]}"

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

  docker buildx build \
    --file="$file" \
    --build-arg="BASE_IMAGE=$last_tag" \
    --cache-from="$CACHE_FROM" \
    --cache-to="$CACHE_TO" \
    --push="true" \
    "${IMAGE_LABELS[@]/#/--label=}" \
    "${tags[@]/#/--tag=}" \
    "$ROOT_DIR"

  last_tag=${tags[0]}
done

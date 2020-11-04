#!/usr/bin/env bash
#
# Generate the docker image tags and labels from the provided inputs.
#
# Example: create-metadata.sh --github-sha=bdf8d3e --github-ref=refs/heads/main --github-repo=murar8/devcontainers
#
# Arguments:
#
# --github-sha        SHA of the commit linked to the image.
# --github-ref        Reference of the commit linked to the image.
# --github-repo       Name of the github repository that hosts the source of the image.
#
# Outputs:
#
#   tags              Tags to be added to the docker image (latest, nightly, ...).
#   labels            Labels to be added to the docker image.
#

set -e

for i in "$@"; do
  case $i in
  --github-sha=*)
    GITHUB_SHA="${i#*=}"
    shift
    ;;
  --github-ref=*)
    GITHUB_REF="${i#*=}"
    shift
    ;;
  --github-repo=*)
    GITHUB_REPOSITORY="${i#*=}"
    shift
    ;;
  *)
    echo "Unknown option: ${i#*=}"
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

check $GITHUB_SHA
check $GITHUB_REF
check $GITHUB_REPOSITORY

# ******** tags ********

REF=${GITHUB_REF##*/}

if [ $REF == "main" ]; then
  TAG="nightly"
  VERSION="$GITHUB_SHA"
else
  TAG="latest"
  VERSION="$REF"
fi

echo "::set-output name=tags::\"$TAG\" \"$VERSION\""

# ******** labels ********

LABELS=(
  "org.opencontainers.image.authors=Lorenzo Murarotto <lnzmrr@gmail.com>"
  "org.opencontainers.image.licenses=MIT"
  "org.opencontainers.image.created=$(date --rfc-3339=seconds)"
  "org.opencontainers.image.source=https://github.com/$GITHUB_REPOSITORY"
  "org.opencontainers.image.version=$VERSION"
)

for ((i = 0; i < ${#LABELS[@]}; i++)); do
  LABELS[$i]=\"${LABELS[$i]}\"
done

echo "::set-output name=labels::${LABELS[@]}"

#!/usr/bin/env bash
#
# build-matrix.sh
#
# DESCRIPTION:  Generate the build matrix in JSON format for parsing.
#
# ENVIRONMENT:  BASE_IMAGES:    list of images that should be used as a base for creating other images.
#               IMAGES:         list of images that should be used as-is.
#
# USAGE: ./build-matrix.sh

set -e

function append_matrix() {
    if [[ ! -z $MATRIX ]]; then MATRIX=$MATRIX,; fi
    MATRIX=$MATRIX$1
}

for base_img in $BASE_IMAGES; do
    append_matrix \{\"base-image\":\"$base_img\"\}
done

for base_img in $BASE_IMAGES; do
    for img in $IMAGES; do
        append_matrix \{\"base-image\":\"$base_img\",\"image\":\"$img\"\}
    done
done

MATRIX=\{\"include\":[$MATRIX]\}

echo "::set-output name=matrix::$MATRIX"

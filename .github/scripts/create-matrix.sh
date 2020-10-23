#!/usr/bin/env bash

set -e

source $(dirname $0)/../../config.sh

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

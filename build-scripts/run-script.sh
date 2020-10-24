#!/usr/bin/env bash
#
# Executes the script in /tmp/build-scripts/ that matches provided script name
# and cleans up the image.
#
# run-script.sh <SCRIPT> [SCRIPT_ARGS...]

SCRIPT="$1"
SCRIPT_ARGS="${@:2}"

/tmp/build-scripts/${SCRIPT}.sh ${SCRIPT_ARGS}

DEBIAN_FRONTEND="noninteractive"

apt-get autoremove -y
apt-get clean -y
rm -rf '/var/lib/apt/lists/*' '/tmp/build-scripts/'

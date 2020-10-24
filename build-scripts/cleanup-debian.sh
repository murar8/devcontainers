#!/usr/bin/env bash
#
# Cleans up the image from the build leftovers.
#

DEBIAN_FRONTEND="noninteractive"

apt-get autoremove -y
apt-get clean -y
rm -rf '/var/lib/apt/lists/*' '/tmp/external-build-scripts/' '/tmp/external-scripts/'

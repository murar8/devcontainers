#!/usr/bin/env bash
#
# Download the docker image configuration scripts from https://github.com/microsoft/vscode-dev-containers
#

SCRIPTS_DIR="$(dirname $0)/../external-build-scripts"

SCRIPTS_VERSION="0.146.0"

TARBALL_URL="https://github.com/microsoft/vscode-dev-containers/archive/v${SCRIPTS_VERSION}.tar.gz"

mkdir -p $SCRIPTS_DIR
curl -fsSL $TARBALL_URL | tar --wildcards --no-wildcards-match-slash -C $SCRIPTS_DIR --strip-components=2 -xzvf - 'vscode-dev-containers-*/script-library/*.sh'

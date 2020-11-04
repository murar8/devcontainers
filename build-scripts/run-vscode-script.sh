#!/usr/bin/env bash
#
# Download and execute one of the scripts from https://github.com/microsoft/vscode-dev-containers.
#
# run-script.sh <script name> <script version> <script-args>...
#

SCRIPT_NAME="$1"
SCRIPT_VERSION="$2"
SCRIPT_ARGS="${@:3}"

set -e

if [ "$(id -u)" -ne 0 ]; then
  echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
  exit 1
fi

if [ "$#" -lt 2 ]; then
  echo "Not enough arguments provided."
  exit 1
fi

DEBIAN_FRONTEND="noninteractive"

if [ ! -d "/var/lib/apt/lists" ] || [ "$(ls /var/lib/apt/lists/ | wc -l)" = "0" ]; then
  apt-get update
fi

packages="apt-utils curl ca-certificates"

if ! dpkg -s $packages; then
  debconf_warning='debconf: delaying package configuration, since apt-utils is not installed'
  apt-get -y install --no-install-recommends $packages 2> >(grep -v "$debconf_warning" >&2)
fi

SCRIPT_URL="https://raw.githubusercontent.com/microsoft/vscode-dev-containers/${SCRIPT_VERSION}/script-library/${SCRIPT_NAME}"

curl -fsSL $SCRIPT_URL | bash -s - $SCRIPT_ARGS

if [ -d "/var/lib/apt/lists" ]; then
  apt-get autoremove -y
  apt-get clean -y
  rm -rf '/var/lib/apt/lists/*'
fi

ARG BASE_IMAGE

FROM ${BASE_IMAGE}

# Installs a set of common command line utilities, Oh My Bash!, Oh My Zsh!, and sets up a non-root user.
# See https://github.com/microsoft/vscode-dev-containers/blob/master/script-library/docs/common.md

ARG TARGET_GO_VERSION="latest"
ARG TARGET_GOROOT="/usr/local/go"
ARG TARGET_GOPATH="/go"
ARG USERNAME="vscode"
ARG UPDATE_RC="true"
ARG INSTALL_GO_TOOLS="true"

COPY ./external-build-scripts/ ./build-scripts/ /tmp/build-scripts/

RUN /tmp/build-scripts/run-script.sh go-debian "${TARGET_GO_VERSION}" "${TARGET_GOROOT}" "${TARGET_GOPATH}" "${USERNAME}" "${UPDATE_RC}" "${INSTALL_GO_TOOLS}"

ARG BASE_IMAGE

FROM ${BASE_IMAGE}

COPY ./build-scripts/ /tmp/build-scripts/

# Installs Go and common Go utilities. Auto-detects latest version and installs needed dependencies.
# See https://github.com/microsoft/vscode-dev-containers/blob/master/script-library/docs/go.md

ARG TARGET_GO_VERSION="latest"
ARG TARGET_GOROOT="/usr/local/go"
ARG TARGET_GOPATH="/go"
ARG USERNAME="automatic"
ARG UPDATE_RC="true"
ARG INSTALL_GO_TOOLS="true"

RUN /tmp/build-scripts/run-vscode-script.sh go-debian.sh master \
  "${TARGET_GO_VERSION}" "${TARGET_GOROOT}" "${TARGET_GOPATH}" "${USERNAME}" "${UPDATE_RC}" "${INSTALL_GO_TOOLS}"

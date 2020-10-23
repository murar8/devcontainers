ARG BASE_IMAGE_TYPE
ARG BASE_IMAGE_TAG

FROM ghcr.io/murar8/devcontainer-${BASE_IMAGE_TYPE}:${BASE_IMAGE_TAG}

# Installs Go and common Go utilities. Auto-detects latest version and installs needed dependencies.
# See https://github.com/microsoft/vscode-dev-containers/blob/master/script-library/docs/go.md

ARG TARGET_GO_VERSION="latest"
ARG TARGET_GOROOT="/usr/local/go"
ARG TARGET_GOPATH="/go"
ARG UPDATE_RC="true"
ARG INSTALL_GO_TOOLS="true"

RUN echo "https://raw.githubusercontent.com/microsoft/vscode-dev-containers/master/script-library/go-debian.sh" \
    | xargs curl -sSL \
    | bash /dev/stdin "${TARGET_GO_VERSION}" "${TARGET_GOROOT}" "${TARGET_GOPATH}" "${UPDATE_RC}" "${INSTALL_GO_TOOLS}" \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

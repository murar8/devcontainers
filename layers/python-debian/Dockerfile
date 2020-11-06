ARG BASE_IMAGE

FROM ${BASE_IMAGE}

COPY ./build-scripts/ /tmp/build-scripts/

# Installs Python, PIPX, and common Python utilities.
# https://github.com/microsoft/vscode-dev-containers/blob/master/script-library/docs/python.md

ARG PYTHON_VERSION="none"
ARG PYTHON_INSTALL_PATH="/usr/local/python${PYTHON_VERSION}"
ARG PIPX_HOME="/usr/local/py-utils"
ARG USERNAME="vscode"
ARG UPDATE_RC="true"
ARG INSTALL_PYTHON_TOOLS="true"

RUN /tmp/build-scripts/run-vscode-script.sh python-debian.sh master \
  "${PYTHON_VERSION}" "${PYTHON_INSTALL_PATH}" "${PIPX_HOME}" "${USERNAME}" "${UPDATE_RC}" "${INSTALL_PYTHON_TOOLS}"

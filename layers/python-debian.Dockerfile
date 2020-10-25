ARG BASE_IMAGE

FROM ${BASE_IMAGE}

# Installs Python, PIPX, and common Python utilities.
# https://github.com/microsoft/vscode-dev-containers/blob/master/script-library/docs/python.md

ARG PYTHON_VERSION="3.8.3"
ARG PYTHON_INSTALL_PATH="/usr/local/python${PYTHON_VERSION}"
ARG PIPX_HOME="/usr/local/py-utils"
ARG USERNAME="automatic"
ARG UPDATE_RC="true"
ARG INSTALL_PYTHON_TOOLS="true"

COPY ./external-build-scripts/ /tmp/build-scripts/

RUN /tmp/build-scripts/python-debian.sh "${PYTHON_VERSION}" "${PYTHON_INSTALL_PATH}" "${PIPX_HOME}" "${USERNAME}" "${UPDATE_RC}" "${INSTALL_PYTHON_TOOLS}" \
  && export DEBIAN_FRONTEND="noninteractive" \
  && apt-get autoremove -y \
  && apt-get clean -y \
  && rm -rf '/var/lib/apt/lists/*' '/tmp/build-scripts/'

ARG BASE_IMAGE

FROM ${BASE_IMAGE}

# Installs a set of common command line utilities, Oh My Bash!, Oh My Zsh!, and sets up a non-root user.
# See https://github.com/microsoft/vscode-dev-containers/blob/master/script-library/docs/common.md

ARG INSTALL_ZSH="true"
ARG USERNAME="vscode"
ARG USER_UID="1000"
ARG USER_GID="${USER_UID}"
ARG UPGRADE_PACKAGES="true"
ARG INSTALL_OH_MYS="false"

COPY ./external-build-scripts/ /tmp/build-scripts/

RUN /tmp/build-scripts/common-debian.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}" "${INSTALL_OH_MYS}" \
  && export DEBIAN_FRONTEND="noninteractive" \
  && apt-get autoremove -y \
  && apt-get clean -y \
  && rm -rf '/var/lib/apt/lists/*' '/tmp/build-scripts/'

# Creates the vscode extensions folder with the correct permissions
# to make it easier to mount them as voulmes as a non-root user.
RUN mkdir -p "/home/${USERNAME}/.vscode-server/extensions" \
  && chown -R "${USERNAME}":"${USERNAME}" "/home/${USERNAME}/.vscode-server"

ARG BASE_IMAGE_TAG

ARG BASE_IMAGE

FROM ${BASE_IMAGE}

COPY ./build-scripts/ /tmp/build-scripts/

# Installs a set of common command line utilities, Oh My Bash!, Oh My Zsh!, and sets up a non-root user.
# See https://github.com/microsoft/vscode-dev-containers/blob/master/script-library/docs/common.md

ARG INSTALL_ZSH="true"
ARG USERNAME="vscode"
ARG USER_UID="1000"
ARG USER_GID="${USER_UID}"
ARG UPGRADE_PACKAGES="true"
ARG INSTALL_OH_MYS="false"

RUN /tmp/build-scripts/run-vscode-script.sh common-debian.sh master \
  "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}" "${INSTALL_OH_MYS}"


# Creates the vscode extensions folder with the correct permissions
# to make it easier to mount them as voulmes as a non-root user.

RUN mkdir -p "/home/${USERNAME}/.vscode-server/extensions" \
  && chown -R "${USERNAME}":"${USERNAME}" "/home/${USERNAME}/.vscode-server"

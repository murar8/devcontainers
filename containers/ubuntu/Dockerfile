FROM ubuntu:latest

# Install curl.
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update  \
    && apt-get -y install --no-install-recommends curl ca-certificates \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Installs a set of common command line utilities, Oh My Bash!, Oh My Zsh!, and sets up a non-root user.
# See https://github.com/microsoft/vscode-dev-containers/blob/master/script-library/docs/common.md

ARG INSTALL_ZSH="true"
ARG USERNAME="vscode"
ARG USER_UID="1000"
ARG USER_GID="${USER_UID}"
ARG UPGRADE_PACKAGES="true"
ARG INSTALL_OH_MYS="false"

RUN echo "https://raw.githubusercontent.com/microsoft/vscode-dev-containers/master/script-library/common-debian.sh" \
    | xargs curl -sSL \
    | bash /dev/stdin "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}" "${INSTALL_OH_MYS}" \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Store zsh history file inside a folder so it can be mounted as a volume.
RUN echo "export HISTFILE=/home/${USERNAME}/.zsh_history/zsh_history" >> "/home/${USERNAME}/.zshenv" \
    && chown -R "${USERNAME}":"${USERNAME}" "/home/${USERNAME}/.zshenv"

# Creates various mountpoints with the correct permissions
# to make it easier to mount them as voulmes as a non-root user.
RUN mkdir -p "/home/${USERNAME}/.zsh_history" "/home/${USERNAME}/.vscode-server/extensions" \
    && chown -R "${USERNAME}":"${USERNAME}" "/home/${USERNAME}/.zsh_history" "/home/${USERNAME}/.vscode-server"

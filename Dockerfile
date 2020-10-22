
ARG TAG="focal"
FROM buildpack-deps:${TAG}-curl

ARG RELEASE="v0.146.0"
ARG USERNAME=vscode

ARG SCRIPT_COMMON=https://raw.githubusercontent.com/microsoft/vscode-dev-containers/$RELEASE/script-library/common-debian.sh
ARG INSTALL_ZSH="true"
ARG USER_UID=1000
ARG USER_GID=$USER_UID
ARG UPGRADE_PACKAGES="true"
ARG INSTALL_OH_MYS="false"
# Installs a set of common command line utilities, Oh My Bash!, Oh My Zsh!, and sets up a non-root user.
# See https://github.com/microsoft/vscode-dev-containers/blob/master/script-library/docs/common.md
RUN curl -sSL "${SCRIPT_COMMON}" \
  | bash /dev/stdin "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}" "${INSTALL_OH_MYS}" \
  && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

ARG SCRIPT_DOCKER="https://raw.githubusercontent.com/microsoft/vscode-dev-containers/${RELEASE}/script-library/docker-debian.sh"
ARG ENABLE_NONROOT_DOCKER="true"
ARG SOURCE_SOCKET="/var/run/docker-host.sock"
ARG TARGET_SOCKET="/var/run/docker.sock"
# Adds the Docker CLI to a container along with a script to enable using a forwarded Docker socket within a container to run Docker commands.
# See https://github.com/microsoft/vscode-dev-containers/blob/master/script-library/docs/docker.md
RUN curl -sSL "${SCRIPT_DOCKER}" \
  | bash /dev/stdin "${ENABLE_NONROOT_DOCKER}" "${SOURCE_SOCKET}" "${TARGET_SOCKET}" "${USERNAME}" \
  && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /home/"${USERNAME}"/.zsh_history /home/"${USERNAME}"/.vscode-server/extensions \
  && chown -R "${USERNAME}":"${USERNAME}" /home/"${USERNAME}"/.zsh_history /home/"${USERNAME}"/.vscode-server

ENV HISTFILE=/home/"${USERNAME}"/.zsh_history/zsh_history

ENTRYPOINT [ "/usr/local/share/docker-init.sh" ]
CMD [ "sleep", "infinity" ]

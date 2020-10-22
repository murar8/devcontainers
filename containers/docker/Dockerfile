ARG BASE_IMAGE_TYPE
ARG BASE_IMAGE_TAG

FROM ghcr.io/murar8/devcontainer-vanilla-base:${BASE_IMAGE_TAG}

# Adds the Docker CLI to a container along with a script to enable using a forwarded Docker socket within a container to run Docker commands.
# See https://github.com/microsoft/vscode-dev-containers/blob/master/script-library/docs/docker.md

ARG USERNAME=vscode
ARG ENABLE_NONROOT_DOCKER="true"
ARG SOURCE_SOCKET="/var/run/docker-host.sock"
ARG TARGET_SOCKET="/var/run/docker.sock"

RUN echo "https://raw.githubusercontent.com/microsoft/vscode-dev-containers/${SCRIPTS_RELEASE}/script-library/docker-debian.sh" \
  | xargs curl -sSL \
  | bash /dev/stdin "${ENABLE_NONROOT_DOCKER}" "${SOURCE_SOCKET}" "${TARGET_SOCKET}" "${USERNAME}" \
  && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

ENTRYPOINT [ "/usr/local/share/docker-init.sh" ]

CMD [ "sleep", "infinity" ]

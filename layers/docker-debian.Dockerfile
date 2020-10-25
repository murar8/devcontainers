ARG BASE_IMAGE

FROM ${BASE_IMAGE}

# Adds the Docker CLI to a container along with a script to enable using a forwarded Docker socket within a container to run Docker commands.
# See https://github.com/microsoft/vscode-dev-containers/blob/master/script-library/docs/docker.md

ARG ENABLE_NONROOT_DOCKER="true"
ARG SOURCE_SOCKET="/var/run/docker-host.sock"
ARG TARGET_SOCKET="/var/run/docker.sock"
ARG USERNAME="vscode"

COPY ./external-build-scripts/ /tmp/build-scripts/

RUN /tmp/build-scripts/docker-debian.sh "${ENABLE_NONROOT_DOCKER}" "${SOURCE_SOCKET}" "${TARGET_SOCKET}" "${USERNAME}" \
  && export DEBIAN_FRONTEND="noninteractive" \
  && apt-get autoremove -y \
  && apt-get clean -y \
  && rm -rf '/var/lib/apt/lists/*' '/tmp/build-scripts/'

ENTRYPOINT [ "/usr/local/share/docker-init.sh" ]

CMD [ "sleep", "infinity" ]

ARG BASE_IMAGE

FROM ${BASE_IMAGE}

COPY ./build-scripts/ /tmp/build-scripts/

# Installs Python, PIPX, and common Python utilities.
# https://github.com/microsoft/vscode-dev-containers/blob/master/script-library/docs/python.md

ENV CARGO_HOME="/usr/local/cargo"
ENV RUSTUP_HOME="/usr/local/rustup"
ENV USERNAME="automatic"
ENV UPDATE_RC="true"
ENV UPDATE_RUST="false"

RUN /tmp/build-scripts/run-vscode-script.sh rust-debian.sh master \
  "${CARGO_HOME}" "${RUSTUP_HOME}" "${USERNAME}" "${USERNAME}" "${UPDATE_RC}" "${UPDATE_RUST}"

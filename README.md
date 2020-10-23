# devcontainers

## Description

This repository contains my development container definitions for VSCode Remote Development.

## Base images

Usage: `ghcr.io/murar8/devcontainer-[BASE IMAGE NAME]:latest`

### ubuntu

- Common command-line utilities and zsh preinstalled.
- Set up with a non-root user named 'vscode'.
- Mountpoints created for persisting zsh history and VSCode extensions folder on container rebuild.

To enable persistence add the following to `devcontainer.json`:

```json
{
  "mounts": [
    "source=ubuntu-zsh-history,target=/home/vscode/.zsh-history,type=volume",
    "source=ubuntu-vscode-extensions,target=/home/vscode/.vscode-server/extensions,type=volume"
  ]
}
```

To use the non-root user add the following to `devcontainer.json`:

```json
{
  "remoteUser": "vscode"
}
```

For more information see https://github.com/microsoft/vscode-dev-containers/blob/master/script-library/docs/common.md

### docker

- Same as above.
- Forward the Docker socket to allow the usage of docker within a container.

To use this image add the following to `devcontainer.json`:

```json
{
  "overrideCommand": false,

  "runArgs": ["--init"],

  "mounts": [
    "source=/var/run/docker.sock,target=/var/run/docker-host.sock,type=bind"
  ],

  "remoteEnv": {
    "LOCAL_WORKSPACE_FOLDER": "${localWorkspaceFolder}"
  },

  "extensions": ["ms-azuretools.vscode-docker"]
}
```

For more information see https://github.com/microsoft/vscode-dev-containers/blob/master/script-library/docs/docker.md

## Images

Usage: `ghcr.io/murar8/devcontainer-[BASE IMAGE NAME]-[IMAGE NAME]:latest`

### golang

- Go and common Go utilities preinstalled.

To use this image add the following to `devcontainer.json`:

```json
{
  "runArgs": ["--cap-add=SYS_PTRACE", "--security-opt", "seccomp=unconfined"],

  "settings": {
    "terminal.integrated.shell.linux": "/bin/bash",
    "go.useGoProxyToCheckForToolUpdates": false,
    "go.useLanguageServer": true,
    "go.gopath": "/go",
    "go.goroot": "/usr/local/go",
    "go.toolsGopath": "/go/bin"
  },

  "extensions": ["golang.Go"]
}
```

For more information see https://github.com/microsoft/vscode-dev-containers/blob/master/script-library/docs/go.md

## Adding a new definition

Base Image vs Image: TODO

- ### Create the Dockerfile in containers/[IMAGE NAME]/Dockerfile.

  If the image is not a base image the format should start with:

  ```Dockefile
    ARG BASE_IMAGE_TYPE
    ARG BASE_IMAGE_TAG
    FROM ghcr.io/murar8/devcontainer-${BASE_IMAGE_TYPE}:${BASE_IMAGE_TAG}
  ```

- ### Add the image name in config.sh to either BASE_IMAGES or IMAGES.

  **Note**: If an image depends on another one it should be specified AFTER the parent in the config
  so the parent image will be built first.

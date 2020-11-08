# devcontainers

## Description

This repository contains some development container definitions for VSCode Remote Development.
Each image is composed by stacking "layers", to make it easier to have different toolchains in a single image.

## Usage

### Prebuilt images

Look in the release-config.json file to discover what kind of prebuilt images are available.
Usage: `ghcr.io/murar8/devcontainer-[IMAGE_NAME]:latest`

Then in devcontainer.json `devcontainer.json`:

```json
{
  "image": "ghcr.io/murar8/devcontainer-[IMAGE_NAME]:latest"
}
```

### Build an image locally

Just use `scripts/build-push.sh`

## Individual layer description

### common-debian

**Only for debian based base images.**

- Common command-line utilities and zsh preinstalled.
- Set up with a non-root user named 'vscode'.
- Mountpoint created for persisting VSCode extensions folder on container rebuild.

To persist the extension folder on rebuild add the following to `devcontainer.json`:

```json
{
  "mounts": ["source=ubuntu-vscode-extensions,target=/home/vscode/.vscode-server/extensions,type=volume"]
}
```

To use the non-root user add the following to `devcontainer.json`:

```json
{
  "remoteUser": "vscode"
}
```

For more information see https://github.com/microsoft/vscode-dev-containers/blob/master/script-library/docs/common.md

### docker-debian

**Only for debian based base images.**

- Forward the Docker socket to allow the usage of docker within a container.

To use this image add the following to `devcontainer.json`:

```json
{
  "overrideCommand": false,

  "runArgs": ["--init"],

  "mounts": ["source=/var/run/docker.sock,target=/var/run/docker-host.sock,type=bind"],

  "remoteEnv": {
    // You need to use the host's paths to reference the workspace folder.
    "LOCAL_WORKSPACE_FOLDER": "${localWorkspaceFolder}"
  },

  "extensions": ["ms-azuretools.vscode-docker"]
}
```

For more information see https://github.com/microsoft/vscode-dev-containers/blob/master/script-library/docs/docker.md

### golang-debian

**Only for debian based base images.**

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

### python-debian

**Only for debian based base images.**

- Python 3 preinstalled.

To use this image add the following to `devcontainer.json`:

```json
{
  "settings": {
    "python.pythonPath": "/usr/local/bin/python",
    "python.linting.enabled": true,
    "python.linting.pylintEnabled": true,
    "python.formatting.autopep8Path": "/usr/local/py-utils/bin/autopep8",
    "python.formatting.blackPath": "/usr/local/py-utils/bin/black",
    "python.formatting.yapfPath": "/usr/local/py-utils/bin/yapf",
    "python.linting.banditPath": "/usr/local/py-utils/bin/bandit",
    "python.linting.flake8Path": "/usr/local/py-utils/bin/flake8",
    "python.linting.mypyPath": "/usr/local/py-utils/bin/mypy",
    "python.linting.pycodestylePath": "/usr/local/py-utils/bin/pycodestyle",
    "python.linting.pydocstylePath": "/usr/local/py-utils/bin/pydocstyle",
    "python.linting.pylintPath": "/usr/local/py-utils/bin/pylint"
  },

  "extensions": ["ms-python.python"]
}
```

For more information see https://github.com/microsoft/vscode-dev-containers/blob/master/script-library/docs/python.md

### rust-debian

**Only for debian based base images.**

- Rust preinstalled.

For more information see https://github.com/microsoft/vscode-dev-containers/blob/master/script-library/docs/rust.md

## Adding a new image definition

Base Image vs Image: TODO

- ### Create the layer's Dockerfile in containers/[IMAGE NAME]/Dockerfile.

  The image should inherit the base image from previous layers like so:

  ```Dockefile
    ARG BASE_IMAGE
    FROM ${BASE_IMAGE}
  ```

- ### Add an entry in release-config.json providing the desired layer composition.

  ```json
  {
    "name": "golang",
    "from": "golang:1",
    "layers": ["common-debian", "go-debian"]
  }
  ```

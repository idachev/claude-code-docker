# Claude Code Docker Development

This document contains all architecture and building instructions for the Claude Code Docker image.

## Key Components

- `Dockerfile`: Defines the Docker image with Node.js and necessary dependencies for running Claude Code
  - Uses node:20 as base image (aligned with Anthropic's official Claude Code devcontainer)
  - Installs required system packages
  - Installs Python and pip for code-index-mcp dependency
  - Sets up environment for Claude Code
  - Build args: `CLAUDE_CODE_VERSION` (default `latest`), `GIT_DELTA_VERSION` (default `0.19.2`)
- Shell scripts for building, running, and publishing the Docker image:
  - `docker-build.sh`: Builds the Docker image locally
  - `docker-run-local.sh`: Runs Claude Code in the Docker container
  - `docker-push.sh`: Pushes the Docker image to Docker Hub

## Setting Up

First copy the `.env-template` to `.env` and edit with your info:

```bash
cp .env-template .env
```

You can configure the following environment variables:
- `IGD_UTILS_DOCKER_IMG`: Docker image name (default: idachev-claude-code)
- `IGD_UTILS_DOCKER_TAG`: Docker image tag (default: latest)

## Building and Publishing

### Building the Docker Image

Build with a single tag:
```bash
./docker-build.sh
```

Build with multiple tags (e.g., version and latest):
```bash
./docker-build.sh 0.2.0 latest
```

This will build the image with the first tag (0.2.0) and then tag it with the second tag (latest).

### Running Claude Code in Docker Locally

```bash
./docker-run-local.sh
```

You can set a custom location for Claude configuration files:

```bash
CLAUDE_CODE_HOME=/path/to/custom/dir ./docker-run-local.sh
```

### Publishing the Docker Image

Push with a single tag:
```bash
./docker-push.sh
```

Push with multiple tags (e.g., version and latest):
```bash
./docker-push.sh 0.2.0 latest
```

This will tag and push both versions to the remote registry.

## Technical Details

The Docker image includes:
- Node.js 20
- Python 3 and pip for code-index-mcp and uv
- Git, zsh, fzf, gh, jq, ripgrep, bat, fd-find, tree, git-delta, nano, vim and other development tools
- iptables/ipset/iproute2/dnsutils for networking and firewall control
- The Claude Code CLI tool (`@anthropic-ai/claude-code`)

Important implementation notes:
- The Docker image switches between root and node users for different installation steps
- The final image uses the node user for security best practices
- Apt cache is cleaned up after all apt commands to reduce image size
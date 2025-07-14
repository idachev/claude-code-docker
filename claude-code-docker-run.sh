#!/bin/bash
[ "$1" = -x ] && shift && set -x
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

DOCKER_IMG=idachev/claude-code:latest

set -e

if [[ -z "${CLAUDE_CODE_HOME}" ]]; then
  CLAUDE_CODE_HOME="${HOME}"
fi

if [[ ! -d "${CLAUDE_CODE_HOME}/.claude" ]]; then
  mkdir -p "${CLAUDE_CODE_HOME}/.claude"
  echo "Created ${CLAUDE_CODE_HOME}/.claude directory"
fi

if [[ ! -f "${CLAUDE_CODE_HOME}/.claude.json" ]]; then
  touch "${CLAUDE_CODE_HOME}/.claude.json"
  echo "Created empty ${CLAUDE_CODE_HOME}/.claude.json file"
fi

CURRENT_DIR=$(pwd)
CURRENT_DIR_BASENAME=$(basename "${CURRENT_DIR}")

DOCKER_NAME="claude-code"

echo "Pulling latest Docker image: ${DOCKER_IMG}"
docker pull "${DOCKER_IMG}"

# shellcheck disable=SC2145
docker run -it --rm \
  --name "${DOCKER_NAME}" \
  -v "${CURRENT_DIR}":"/workspace/${CURRENT_DIR_BASENAME}" \
  -v "${CLAUDE_CODE_HOME}/.claude":"/home/node/.claude" \
  -v "${CLAUDE_CODE_HOME}/.claude.json":"/home/node/.claude.json" \
  --entrypoint /bin/zsh \
  "${DOCKER_IMG}" \
  -c 'cd /workspace/"'"${CURRENT_DIR_BASENAME}"'" && claude "'"${@}"'" && zsh'

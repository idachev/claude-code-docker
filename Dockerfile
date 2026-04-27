FROM node:20

ARG TZ
ENV TZ="$TZ"

# Build-time pins. Override with `docker build --build-arg ...`.
ARG CLAUDE_CODE_VERSION=latest
ARG GIT_DELTA_VERSION=0.19.2

# System tooling. Aligned with Anthropic's official Claude Code devcontainer
# (less/git/procps/sudo/fzf/zsh/man-db/unzip/gnupg2/gh/iptables/ipset/iproute2/
# dnsutils/aggregate/jq/nano/vim) plus extras useful in Claude Code workflows
# (ripgrep, bat, fd-find, tree, wget, curl, ca-certificates, python3+pip).
# Note: Claude Code ships its own bundled ripgrep; the system copy is kept for
# general shell use and as a fallback (USE_BUILTIN_RIPGREP=0).
RUN apt-get update && apt-get install -y --no-install-recommends \
    less \
    git \
    procps \
    sudo \
    fzf \
    zsh \
    man-db \
    unzip \
    gnupg2 \
    gh \
    iptables \
    ipset \
    iproute2 \
    dnsutils \
    aggregate \
    ripgrep \
    bat \
    fd-find \
    tree \
    jq \
    wget \
    curl \
    ca-certificates \
    nano \
    vim \
    python3 \
    python3-pip \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /usr/local/share/npm-global && \
  chown -R node:node /usr/local/share

ARG USERNAME=node

RUN SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
  && mkdir /commandhistory \
  && touch /commandhistory/.bash_history \
  && chown -R $USERNAME /commandhistory

ENV DEVCONTAINER=true

RUN mkdir -p /workspace /home/node/.claude && \
  chown -R node:node /workspace /home/node/.claude

WORKDIR /workspace

RUN ARCH=$(dpkg --print-architecture) && \
  wget "https://github.com/dandavison/delta/releases/download/${GIT_DELTA_VERSION}/git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb" && \
  dpkg -i "git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb" && \
  rm "git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb"

USER node

ENV NPM_CONFIG_PREFIX=/usr/local/share/npm-global
ENV PATH=$PATH:/usr/local/share/npm-global/bin:/home/node/.local/bin

ENV SHELL=/bin/zsh

RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.2.1/zsh-in-docker.sh)" -- \
  -p git \
  -p fzf \
  -a "source /usr/share/doc/fzf/examples/key-bindings.zsh" \
  -a "source /usr/share/doc/fzf/examples/completion.zsh" \
  -a "export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
  -x

COPY version.txt /home/node/version.txt

# https://github.com/johnhuang316/code-index-mcp
RUN pip install --upgrade --break-system-packages code-index-mcp

RUN pip install --upgrade --break-system-packages uv

RUN npm install -g @anthropic-ai/claude-code@${CLAUDE_CODE_VERSION}

USER node

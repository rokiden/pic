# Use the LTS version of Node.js on Alpine Linux
FROM docker.io/node:lts-alpine

# Install system dependencies
# Note: build-base is the Alpine equivalent of build-essential
# bash is added because the wrapper script explicitly relies on /bin/bash
RUN apk update && apk add --no-cache \
    bash \
    build-base \
    curl \
    fd \
    findutils \
    fuse-overlayfs \
    git \
    grep \
    jq \
    mandoc \
    nmap-ncat \
    podman \
    podman-remote \
    python3 \
    ripgrep \
    shellcheck \
    vim

# Use Bash as root's login shell.
RUN sed -i 's#^root:x:0:0:root:/root:/bin/sh$#root:x:0:0:root:/root:/bin/bash#' /etc/passwd

# Enable package caching for runtime apk installs. pic mounts a persistent
# Podman volume at /var/cache/apk.
RUN ln -s /var/cache/apk /etc/apk/cache

# Podman-in-podman configuration: https://github.com/podman-container-tools/image_build/blob/main/podman
# _CONTAINERS_USERNS_CONFIGURED and BUILDAH_ISOLATION are unnecessary for this setup.
ADD /src/containers.conf /etc/containers/containers.conf

# Configure the dedicated rootless Podman user.
RUN adduser -D -u 1001 -s /bin/bash podman
ADD /src/user-containers.conf /home/podman/.config/containers/containers.conf
RUN chown podman:podman -R /home/podman && \
    echo 'podman:2000:65536' | tee -a /etc/subuid /etc/subgid >/dev/null

# Set default editor to vim
ENV EDITOR=vim

# Install the Pi coding agent and Pi Web globally via npm
RUN npm install -g --ignore-scripts @earendil-works/pi-coding-agent
RUN npm install -g --ignore-scripts @agegr/pi-web@latest
# Rebuild only node-pty from source for Alpine compatibility.
RUN npm_config_build_from_source=true npm rebuild -g node-pty --foreground-scripts

# Working directory is set per-project via podman -w
# Base path for mounted project directories
WORKDIR /wd

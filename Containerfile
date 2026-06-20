# Use the requested lightweight Alpine-based Node 26 image
FROM node:26-alpine

# Install system dependencies
# Note: build-base is the Alpine equivalent of build-essential
# bash is added because the wrapper script explicitly relies on /bin/bash
RUN apk update && apk add --no-cache \
    bash \
    git \
    curl \
    build-base \
    python3 \
    vim \
    mandoc

# Set default editor to vim
ENV EDITOR=vim

# Install the Pi coding agent globally via npm
RUN npm install -g --ignore-scripts @earendil-works/pi-coding-agent

# Working directory is set per-project via podman -w
# Base path for mounted project directories
WORKDIR /wd

# Start with the Pi coding agent
CMD ["pi"]

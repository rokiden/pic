# Use the requested lightweight Alpine-based Node 26 image
FROM node:26-alpine

# Install system dependencies
# Note: build-base is the Alpine equivalent of build-essential
# bash is added because the wrapper script explicitly relies on /bin/bash
RUN apk update && apk add --no-cache \
    bash \
    tmux \
    git \
    curl \
    build-base \
    python3 \
    vim

# Install the Pi coding agent globally via npm
RUN npm install -g --ignore-scripts @earendil-works/pi-coding-agent

# Configure tmux globally for optimal Pi usage (extended keys support and mouse mode)
RUN echo "set -g extended-keys on" >> /etc/tmux.conf && \
    echo "set -g extended-keys-format csi-u" >> /etc/tmux.conf && \
    echo "set -g mouse on" >> /etc/tmux.conf

# Set the default working directory
WORKDIR /wd

# Start with a standard shell; the wrapper handles the tmux launch
CMD ["/bin/bash"]

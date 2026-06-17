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
    vim

# Install the Pi coding agent globally via npm
RUN npm install -g --ignore-scripts @earendil-works/pi-coding-agent

# Set the default working directory
WORKDIR /wd

# Start with the Pi coding agent
CMD ["pi"]

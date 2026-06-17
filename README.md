# pic (Pi Container)

A lightweight Podman wrapper that runs the [Pi coding agent](https://github.com/earendil-works/pi-coding-agent) inside an ephemeral, per-project container.

## What it does

- Launches a fresh Alpine-based Node 26 container with `pi` pre-installed
- Mounts the current project directory into `/wd/<project-slug>`
- Shares your Pi agent config (`~/.config/pi-agent`) into the container at `/home/node/.pi`
- Automatically cleans up and removes the container on exit

## Prerequisites

- [Podman](https://podman.io/) installed and working
- The `pic` script available in your `$PATH`

## Setup

Build the container image once (relative to this directory):

```bash
podman build -t pic:latest .
```

## Usage

Run `pic` from any project directory. A fresh container is created for each invocation and self-destructs afterward. All arguments are forwarded directly to `pi`:

```bash
pic                    # Interactive session with default pi args
pic --help             # Forwarded to: pi --help
pic chat "explain this code"  # Forwarded to: pi chat "explain this code"
pic -p prompts/        # Pass any valid pi flag/arg
```

## Internals

Each container is named `pic_<project-slug>` where `<project-slug>` is the sanitized basename of `$PWD`. The project root is mounted at `/wd/<project-slug>`. This allows multiple projects to run concurrently (each with its own container) while sharing the same image.

```
┌───────────── Podman ─────────────┐
│  Container: pic_<slug>           │
│                                  │
│  /home/node/.pi  ← ~/.config/pi-agent  (rw)
│  /wd/<slug>/     ← $PWD               (rw project)
│                                  │
│  CMD: pi "$@"                    │
└──────────────────────────────────┘
```

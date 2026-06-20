# pic (Pi Container)

A lightweight Podman wrapper that runs the [Pi coding agent](https://github.com/earendil-works/pi-coding-agent) inside an ephemeral, per-project container.

## What it does

- Launches a fresh Alpine-based Node 26 container with `pi` pre-installed
- Mounts the current project directory into `/wd/<project-slug>`
- Shares bundled agent config (`./config/`) into the container at `/root/.pi`
- Automatically cleans up and removes the container on exit

## Configuration

The `pic` script ships with a self-contained agent configuration under `config/agent/`. This includes:

- `AGENTS.md` — global coding instructions & workflow conventions
- `git-workflow.md` — branch naming & commit message rules
- `prompts/commit.md` — commit message template
- `keybindings.json` — editor keybindings
- `settings.json` — agent settings

To customise the agent behavior, edit files in `config/agent/` directly.

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

## Aliases (Optional)

Add these to your shell's profile (`~/.bashrc`, `~/.zshrc`, etc.) for convenience:

```bash
alias pic='~/Documents/pic/pic'
alias pict='pic --tmp'
```

- `pic` — invokes the `pic` script from its install location
- `pict` — runs `pic` in a temporary/interactive session via `--tmp`

## Internals

Each container is named `pic_<project-slug>` where `<project-slug>` is the sanitized basename of `$PWD`. The project root is mounted at `/wd/<project-slug>`. This allows multiple projects to run concurrently (each with its own container) while sharing the same image.

```
┌───────────── Podman ─────────────┐
│  Container: pic_<slug>           │
│                                  │
│  /root/.pi       ← ./config/              (rw bundled config)
│  /wd/<slug>/     ← $PWD               (rw project)
│                                  │
│  CMD: pi "$@"                    │
└──────────────────────────────────┘
```

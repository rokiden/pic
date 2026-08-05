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

Pull the prebuilt image (rebuilt nightly via GitHub Actions when the base image or pi release changes):

```bash
podman pull ghcr.io/rokiden/pic:latest
```

Or build it locally (relative to this directory):

```bash
podman build --pull=always -t ghcr.io/rokiden/pic:latest .
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
alias pic_hostops='~/Documents/pic/hostops.sh'
```

- `pic` — invokes the `pic` script from its install location
- `pict` — runs `pic` in a temporary/interactive session via `--tmp`
- `pic_hostops` — starts `hostops.sh` from its install location

## HostOps

`hostops.sh` is a localhost-only command bridge that lets the agent run predefined operations on the host, optionally with root privileges—for example, VM management. Every `CMD_*` environment variable is exposed as a lowercase, hyphen-separated command. It listens on port `8765` by default; pass another port as the first argument to override it, or pass `sudo` to restart the server with root privileges. `ncat` is required on the host and is included in the `pic` image for agent use.

```bash
CMD_VM_REBOOT='virsh reboot vm' pic_hostops

echo vm-reboot | ncat --no-shutdown 127.0.0.1 8765
```

Commands execute in the host shell, so expose only trusted, deliberately predefined operations and keep the server bound to localhost. If root access is required, use the `sudo` mode so the `CMD_*` definitions are preserved:

```bash
CMD_VM_REBOOT='virsh reboot vm' pic_hostops sudo
```

### Agent usage

Tell the agent it can perform host operations when needed. For example, the `CMD_VM_REBOOT` operation defined above can be requested with this prompt:

```text
You can reboot the VM when needed. Run the predefined host operation with:
echo vm-reboot | ncat --no-shutdown 127.0.0.1 8765
Report the returned result.
```

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

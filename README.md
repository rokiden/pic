# pic (Pi Container)

A lightweight Podman wrapper that runs the [Pi coding agent](https://github.com/earendil-works/pi-coding-agent) in an ephemeral, per-project container or starts the Pi Web UI in a detached per-project container.

## What it does

- Launches a fresh Alpine-based Node.js LTS container with `pi` pre-installed
- Mounts the current project directory into `/wd/<project-slug>`
- Shares bundled agent config (`./config/`) into the container at `/root/.pi`
- With `--pic-podman`, exposes the host's user podman socket so the container's `podman-remote` client can manage host containers
- With `--pic-web`, starts the Pi Web UI with the current project mounted as its working directory
- Removes default Pi containers on exit; Pi Web containers stay running until stopped

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
- `ss` from `iproute2` on the host (required for `--pic-web`)

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

Run `pic` from any project directory. In default Pi mode, a fresh container is created for each invocation and removed on exit. `--pic-web` starts a detached container that remains running after `pic` exits; if that container already exists, `pic` prints its URL instead of starting another. Stop it with `podman stop picweb_<project-slug>`, where the slug is the sanitized project-directory name. In the default mode, arguments are forwarded directly to `pi`:

```bash
pic                    # Interactive session with default pi args
pic --help             # Forwarded to: pi --help
pic chat "explain this code"  # Forwarded to: pi chat "explain this code"
pic -p prompts/        # Pass any valid pi flag/arg
pic --pic-web          # Start Pi Web on an available port from 8000 upward
```

## Session cleanup

With `--pic-web`, Pi sessions are stored in the current project’s `.pi/sessions/` directory, mounted at `/root/.pi/agent/sessions`. Default `pi` mode continues to use the bundled `config/agent/sessions` directory. To delete Pi Web sessions with no activity in the last two weeks:

```bash
find .pi/sessions -name "*.jsonl" -mtime +14 -delete
```

To also remove any left-behind empty subdirectories:

```bash
find .pi/sessions -mindepth 1 -type d -empty -delete
```

## Flags

Wrapper flags are consumed by `pic`; in default mode, other arguments are forwarded to `pi`:

- `--pic-tmp` — run in a fresh temporary directory instead of `$PWD` (removed on exit)
- `--pic-podman` — start the host's socket-activated user podman service (`systemctl --user start podman.socket`) and mount the user podman socket into the container, so the `podman-remote` client preinstalled in the image can manage the host's containers. The host socket `$XDG_RUNTIME_DIR/podman/podman.sock` is mounted at `/run/podman/podman.sock` and `CONTAINER_HOST=unix:///run/podman/podman.sock` is set inside the container.
- `--pic-web` — run the `pi-web` command. `pic` uses `ss` to check listening TCP ports on the host, scans from port 8000 upward, and passes the first port not reported as listening to Pi Web via `PORT`. Open the UI at `http://127.0.0.1:<port>`. Pi CLI arguments and `--pic-tmp` cannot be combined with this mode.

## Aliases (Optional)

Add these to your shell's profile (`~/.bashrc`, `~/.zshrc`, etc.) for convenience:

```bash
alias pic='~/Documents/pic/pic'
alias pict='pic --pic-tmp'
alias pic_hostops='~/Documents/pic/hostops.sh'
```

- `pic` — invokes the `pic` script from its install location
- `pict` — runs `pic` in a temporary/interactive session via `--pic-tmp`
- `pic_hostops` — starts `hostops.sh` from its install location

## HostOps

`hostops.sh` is a command bridge that lets the agent run predefined operations on the host, optionally with root privileges—for example, VM management. Every `CMD_*` environment variable is exposed as a lowercase, hyphen-separated command. It listens on `127.0.0.1:8765` by default; pass `listen=HOST:PORT` and/or `sudo` in any order to override the default or restart the server with root privileges. `ncat` is required on the host and is included in the `pic` image for agent use.

```bash
CMD_VM_REBOOT='virsh reboot vm' pic_hostops

echo vm-reboot | ncat --no-shutdown 127.0.0.1 8765

# Listen on all interfaces (use only when remote access is intentional).
CMD_VM_REBOOT='virsh reboot vm' pic_hostops listen=0.0.0.0:8765
```

Commands execute in the host shell, so expose only trusted, deliberately predefined operations. Keep the server bound to localhost unless remote access is intentional. If root access is required, use the `sudo` mode so the `CMD_*` definitions are preserved:

```bash
CMD_VM_REBOOT='virsh reboot vm' pic_hostops sudo listen=127.0.0.1:8765
```

### Agent usage

Tell the agent it can perform host operations when needed. For example, the `CMD_VM_REBOOT` operation defined above can be requested with this prompt:

```text
You can reboot the VM when needed. Run the predefined host operation with:
echo vm-reboot | ncat --no-shutdown 127.0.0.1 8765
Report the returned result.
```

## Internals

Default Pi containers are named `pic_<project-slug>`; detached Pi Web containers are named `picweb_<project-slug>`. The project root is mounted at `/wd/<project-slug>`, where `<project-slug>` is the sanitized basename of `$PWD`. This allows multiple projects to run concurrently while sharing the same image. The diagram shows the default Pi mode:

```
┌───────────── Podman ─────────────┐
│  Container: pic_<slug>           │
│                                  │
│  /root/.pi       ← ./config/              (rw bundled config)
│  /wd/<slug>/     ← $PWD               (rw project)
│  /run/podman/    ← $XDG_RUNTIME_DIR/podman/podman.sock  (rw, only with --pic-podman)
│                                  │
│  CMD: pi "$@"                    │
└──────────────────────────────────┘
```

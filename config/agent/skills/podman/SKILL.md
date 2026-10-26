---
name: podman
description: "Rootless Podman workflows in the agent's container environment and host Podman socket integration."
---

# Podman

Use the dedicated `podman` user and fully qualified image refs only:
`docker.io/library/alpine:latest`, `localhost/name:tag`.

## Local rootless Podman

Run the following commands inside your container environment; each invokes
Podman as the dedicated `podman` user.

### Build and run

```sh
su - podman -c 'podman build -t localhost/my-image:latest /path/context'
su - podman -c 'podman run --rm docker.io/library/alpine:latest echo OK'
```

The build context and its `Containerfile`, `ADD`, and `COPY` sources must be
readable by `podman`; every parent directory must be searchable (have execute
permission). Since `su -` changes to `/home/podman`, use an absolute context
path and avoid paths under `/root`. `mktemp -d` creates a private directory by
default; create the context as `podman` or adjust its ownership and permissions
before building.

Use `su - podman -c 'podman ...'` for other local container and image
operations. Local images belong to the dedicated user's rootless store, separate
from root storage and the host store accessed via `podman-remote`.

For UID-range diagnostics and host allocation guidance, see
[UID-range troubleshooting](uid-range-troubleshooting.md).


## Host socket (explicit opt-in)

Use the host socket only when the user explicitly requests managing host
containers or images. The user must start `pic` agent with `--pic-podman` to mount
`/run/podman/podman.sock` and set `CONTAINER_HOST` inside the container.

The same container and image operations are available as
`podman-remote <command>`. Run `podman-remote` directly, not through `su -`,
which clears `CONTAINER_HOST`. Remote commands use the host service and image
store, separate from the local rootless store. Host-local commands such as
`podman unshare` and `podman system migrate` must run directly on the host.

Verify access with:

```sh
podman-remote info
```

If the socket is unavailable, ask the user to restart with `--pic-podman`.

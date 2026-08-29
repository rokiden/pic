---
name: podman
description: "Build and run OCI images with rootless Podman in restricted Alpine."
---

# Podman

Use the dedicated `podman` user and fully qualified image refs only:
`docker.io/library/alpine:latest`, `localhost/name:tag`.

## Setup (outer root; once)

```sh
apk add podman
id podman >/dev/null 2>&1 || adduser -D -u 1001 -s /bin/sh podman
grep -q '^podman:' /etc/subuid 2>/dev/null || printf '%s\n' 'podman:1002:64535' >> /etc/subuid
grep -q '^podman:' /etc/subgid 2>/dev/null || printf '%s\n' 'podman:1002:64535' >> /etc/subgid
su - podman -c 'podman system migrate'
```

## Build

```sh
su - podman -c 'podman build --isolation=chroot --network=host -t localhost/my-image:latest /path/context'
```

## Run

```sh
su - podman -c 'podman run --rm --network=host --uts=host --pid=host docker.io/library/alpine:latest echo OK'
```

`--isolation=chroot` is required for builds; `--network=host`, `--uts=host`,
and `--pid=host` are required for runs here.

## Working container

```sh
su - podman -c 'podman create --name work --network=host --uts=host --pid=host localhost/my-image:latest'
su - podman -c 'podman cp /path/src work:/path/dst'
su - podman -c 'podman start -a work'       # initial command
su - podman -c 'podman exec work command'   # while running
su - podman -c 'podman commit work localhost/my-image:changed'
su - podman -c 'podman rm work'
```

## Save/load

```sh
su - podman -c 'podman save --format oci-archive -o /path/image.tar localhost/my-image:latest'
su - podman -c 'podman load -i /path/image.tar'
su - podman -c 'podman import /path/rootfs.tar localhost/my-image:latest' # rootfs tar only
```

Images belong to Podman’s rootless `podman` store, separate from root storage.

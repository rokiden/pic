---
name: containers
description: "Build, export, and run OCI images with Buildah in this restricted Alpine environment."
---

# Containers

## Install

```bash
apk add buildah netavark
```

Netavark is required by Buildah in this environment, including chroot builds
and runs. The Alpine Buildah package brings in the other container runtime
dependencies. Chroot mode uses the host network; other network modes are not
supported with `--isolation=chroot`.

## Build

Use chroot isolation for every Buildah build or run here; the default OCI
/rootless path fails against the read-only `/proc/sys` filesystem. Use fully
qualified image references.

```bash
buildah build --isolation=chroot -t <image-name> <context-path>
```

## Export

```bash
buildah push <image-name> docker-archive:/path/to/image.tar
buildah push <image-name> oci:/path/to/image-dir
buildah push <image-name> oci-archive:/path/to/image.tar
```

## Import

```bash
buildah from --name <container> docker-archive:/path/to/image.tar
buildah from --name <container> oci:/path/to/image-dir
buildah from --name <container> oci-archive:/path/to/image.tar
```

## Working container

```bash
buildah from --name <container> <image-name>  # --name must precede image
buildah copy <container> <src> <dst>
buildah run --isolation=chroot <container> <command>
buildah commit <container> <new-image-name>
buildah rm <container>
```

Every command that executes a process in a container must use
`--isolation=chroot`. Package managers work in chroot mode and use the host
network. Use `buildah rm --all` only when all working containers in the local
store are disposable.

# Podman UID-range troubleshooting

Inspect your container environment's account and mappings:

```sh
id podman
grep '^podman:' /etc/subuid /etc/subgid
cat /proc/self/uid_map /proc/self/gid_map
```

Mapping errors can also originate in the host account running the Podman
runtime that launched your container environment. You cannot inspect or change
the host's subuid/subgid files from inside your container environment. If your
local ranges look correct, ask the user to run these commands in a host shell
and share the output:

```sh
grep "^$(id -un):" /etc/subuid /etc/subgid
podman unshare cat /proc/self/uid_map
podman unshare cat /proc/self/gid_map
```

For nested Podman, recommend a 128 Ki-ID host allocation. On the host, manually
edit `/etc/subuid` and `/etc/subgid` as an administrator to add this entry for
the host account:

```text
HOST_USER:524288:131072
```

If the account already has an entry, update it rather than appending a
duplicate. Ensure the range does not overlap another host user's allocation.
After saving both files, run this as the host account:

```sh
podman system migrate
```

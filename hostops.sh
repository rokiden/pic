#!/usr/bin/env bash
# HostOps — lightweight local shell-command server.
# Uses a self-referencing ncat handler and no temporary files.
# Binds to 127.0.0.1 only (localhost).
# Every CMD_* environment variable becomes a command. For example:
#   CMD_VM_REBOOT_BIOS='virsh ...; qemu-img ... && virsh ...' ./hostops.sh 8765
# The variable above is served as the command "vm-reboot-bios".
# Client: echo vm-reboot-bios | ncat --no-shutdown 127.0.0.1 8765

set -uo pipefail

available_commands() {
    local variable suffix
    local -a commands=()

    while IFS= read -r variable; do
        [[ "$variable" =~ ^CMD_[A-Za-z0-9_]+$ ]] || continue
        suffix=${variable#CMD_}
        suffix=${suffix,,}
        commands+=("${suffix//_/-}")
    done < <(compgen -A variable CMD_)

    if ((${#commands[@]} == 0)); then
        printf '%s' '(none)'
    else
        local IFS=' '
        printf '%s' "${commands[*]}"
    fi
}

if [[ "${HOSTOPS_HANDLER:-}" == "1" ]]; then
    # ─────────────── HANDLER MODE (ncat -e fork) ───────────────
    # CMD_VM_REBOOT_BIOS is exposed as the command vm-reboot-bios:
    # uppercase the request and replace hyphens with underscores to find
    # the corresponding shell variable.

    line=
    read -r line 2>/dev/null || true
    cmd=$(printf '%s' "$line" | tr -d '[:space:]')

    printf '%s Executing: %s\n' "$(date -u '+%Y-%m-%d %H:%M:%S UTC')" "$cmd" >&2

    variable=
    if [[ "$cmd" =~ ^[A-Za-z0-9_-]+$ ]]; then
        variable="CMD_${cmd^^}"
        variable=${variable//-/_}
    fi

    if [[ -n "$variable" && -v "$variable" ]]; then
        command_string=${!variable}
        if result=$(bash -c "$command_string" "$cmd" 2>&1); then
            :
        else
            status=$?
            [[ -n "$result" ]] && result+=$'\n'
            result+="$cmd FAILED: $status"
        fi
    else
        result=$(printf 'unknown command: %s\navailable commands: %s' "$cmd" "$(available_commands)")
    fi

    printf '%s\n' "$result"
    exit 0
fi

# ─────────────── SERVER MODE (original process) ───────────────
SCRIPT="$(readlink -f "$0")"

if [[ "${1:-}" == "sudo" ]]; then
    shift

    # sudo normally resets the environment. Preserve exactly the CMD_*
    # variables that define the commands, rather than the entire environment.
    cmd_env_names=()
    while IFS= read -r variable; do
        [[ "$variable" =~ ^CMD_[A-Za-z0-9_]+$ ]] || continue
        cmd_env_names+=("$variable")
    done < <(compgen -A variable CMD_)

    printf 'HostOps: restarting with sudo (port %s; preserving %d CMD_* variables).\n' \
        "${1:-8765}" "${#cmd_env_names[@]}" >&2

    if ((${#cmd_env_names[@]} > 0)); then
        preserved_env=
        for variable in "${cmd_env_names[@]}"; do
            [[ -z "$preserved_env" ]] || preserved_env+=,
            preserved_env+="$variable"
        done
        exec sudo --preserve-env="$preserved_env" "$SCRIPT" "$@"
    fi

    exec sudo "$SCRIPT" "$@"
fi

if ! command -v ncat >/dev/null 2>&1; then
    printf '%s\n' 'hostops.sh: ncat is required in server mode' >&2
    exit 127
fi

PORT="${1:-8765}"
echo "🐧 HostOps server on 127.0.0.1:$PORT (Ctrl+C)" >&2
echo "Available commands: $(available_commands)" >&2

trap 'exit' INT TERM

while true; do
    HOSTOPS_HANDLER=1 ncat --listen --keep-open -e "$SCRIPT" 127.0.0.1 "$PORT"
    status=$?
    printf 'HostOps listener exited with status %d; retrying in 1 second.\n' "$status" >&2
    sleep 1
done

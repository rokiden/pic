#!/usr/bin/env bash
# HostOps — lightweight local shell-command server.
# Uses a self-referencing socat handler and no temporary files.
# Binds to 127.0.0.1:8765 by default; override with listen=HOST:PORT.
# Every CMD_* environment variable becomes a command. For example:
#   CMD_VM_REBOOT_BIOS='virsh ...; qemu-img ... && virsh ...' ./hostops.sh
# The variable above is served as the command "vm-reboot-bios".
# Server uses socat (never exposes the raw client socket to CMD_* commands
# or anything they background). Client can be any TCP tool; ncat needs
# --no-shutdown to keep reading after stdin closes:
# Client: echo vm-reboot-bios | ncat --no-shutdown 127.0.0.1 8765
# Usage:
#   ./hostops.sh [sudo] [listen=HOST:PORT]
#
# Arguments may be supplied in any order.
#
# Functions:
#   die                  MESSAGE [STATUS]  print a fatal error and exit
#   parse_args           ARGS...           parse server arguments
#   restart_with_sudo                      restart the server as root
#   available_commands                      print the exposed commands

set -euo pipefail

##############################################################################
# functions
##############################################################################

# die #######################################################################
# Actions:
# - print a fatal error
# - exit with the supplied status
# Usage:
#   die "socat is required" 127
die() {
    local _message=$1
    local _status=${2:-1}

    printf 'hostops.sh: %s\n' "$_message" >&2
    exit "$_status"
}

# parse_args #################################################################
# Actions:
# - parse the optional listen=HOST:PORT and sudo arguments
# - populate PORT, LISTEN_HOST, and USE_SUDO
# Notes:
# - accepts arguments in any order
# Usage:
#   parse_args "$@"
parse_args() {
    local _arg _key _value _host _port

    while (($# > 0)); do
        _arg=$1
        shift

        if [[ "$_arg" == *=* ]]; then
            _key=${_arg%%=*}
            _value=${_arg#*=}
            case "$_key" in
                listen)
                    [[ -n "$_value" ]] || die 'listen= requires HOST:PORT'
                    if [[ "$_value" == *:* ]]; then
                        _host=${_value%:*}
                        _port=${_value##*:}
                    else
                        die 'listen= requires HOST:PORT'
                    fi
                    [[ -n "$_host" ]] || die 'listen= requires a host'
                    [[ "$_port" =~ ^[0-9]+$ ]] || die 'listen= requires a numeric port'
                    LISTEN_HOST=$_host
                    PORT=$_port
                    ;;
                *)
                    die "unknown argument: $_arg"
                    ;;
            esac
        elif [[ "$_arg" == 'sudo' ]]; then
            USE_SUDO=1
        else
            die "unknown argument: $_arg"
        fi
    done
}

# restart_with_sudo #########################################################
# Actions:
# - preserve CMD_* variables
# - restart the server with root privileges
# Usage:
#   restart_with_sudo
restart_with_sudo() {
    local _variable
    local _preserved_env=
    local -a _cmd_env_names=()
    local -a _sudo_args=("listen=$LISTEN_HOST:$PORT")

    while IFS= read -r _variable; do
        [[ "$_variable" =~ ^CMD_[A-Za-z0-9_]+$ ]] || continue
        _cmd_env_names+=("$_variable")
    done < <(compgen -A variable CMD_)

    printf 'HostOps: restarting with sudo (host %s, port %s; preserving %d CMD_* variables).\n' \
        "$LISTEN_HOST" "$PORT" "${#_cmd_env_names[@]}" >&2

    if ((${#_cmd_env_names[@]} > 0)); then
        for _variable in "${_cmd_env_names[@]}"; do
            [[ -z "$_preserved_env" ]] || _preserved_env+=,
            _preserved_env+="$_variable"
        done
        exec sudo --preserve-env="$_preserved_env" "$SCRIPT" "${_sudo_args[@]}"
    fi

    exec sudo "$SCRIPT" "${_sudo_args[@]}"
}

# available_commands #########################################################
# Actions:
# - print the exposed command names
# - print (none) when no commands are configured
# Usage:
#   available_commands
available_commands() {
    local _variable _suffix
    local -a _commands=()

    while IFS= read -r _variable; do
        [[ "$_variable" =~ ^CMD_[A-Za-z0-9_]+$ ]] || continue
        _suffix=${_variable#CMD_}
        _suffix=${_suffix,,}
        _commands+=("${_suffix//_/-}")
    done < <(compgen -A variable CMD_)

    if ((${#_commands[@]} == 0)); then
        printf '%s' '(none)'
    else
        local IFS=' '
        printf '%s' "${_commands[*]}"
    fi
}

if [[ "${HOSTOPS_HANDLER:-}" == "1" ]]; then
    # ─────────────── HANDLER MODE (socat EXEC fork) ───────────────
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
        if result=$(bash -c "$command_string" "$cmd" </dev/null 2>&1); then
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

PORT=8765
LISTEN_HOST=127.0.0.1
USE_SUDO=0
parse_args "$@"

if ((USE_SUDO == 1)); then
    restart_with_sudo
fi

if ! command -v socat >/dev/null 2>&1; then
    die 'socat is required in server mode' 127
fi

printf '🐧 HostOps server on %s:%s (Ctrl+C)\n' "$LISTEN_HOST" "$PORT" >&2
printf 'Available commands: %s\n' "$(available_commands)" >&2

trap 'exit' INT TERM

while true; do
    # -t3600: keep waiting on slow CMD_* commands instead of giving up 0.5s
    # (socat's default) after the client's side of the connection hits EOF.
    if HOSTOPS_HANDLER=1 socat -t3600 "TCP-LISTEN:$PORT,bind=$LISTEN_HOST,reuseaddr,fork" EXEC:"$SCRIPT"; then
        status=0
    else
        status=$?
    fi
    printf 'HostOps listener exited with status %d; retrying in 1 second.\n' "$status" >&2
    sleep 1
done

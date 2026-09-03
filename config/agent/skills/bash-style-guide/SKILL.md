---
name: bash-style-guide
description: 'Bash script style guide. USE FOR: writing or reviewing bash scripts; formatting comments, sections and function headers consistently.'
---

# Bash style guide

## File header

- One `#` comment block at the top of the file.
- List format, no prose paragraphs. Sections only if non-empty:
  - a few line description + `Usage:` (or the CLI invocation) with an indented example
  - `Reads files:` — files consumed
  - `Writes files:` — files produced
  - `Env mandatory:` — required environment variables
  - `Env optional:` — optional environment variables and their defaults
  - `Variables required:` / `Variables provided:` — for libraries meant to be sourced
  - `Functions:` — name + one-line summary, aligned in a table-ish list
- `set -euo pipefail` immediately after the header, before any section.

## Sections

- Top-level groupings (`config`, `functions`, `variables`, `arg parsing`, `main`, ...).
- Delimited by a 3-line, 78-`#` separator, lowercase name on the middle line:
  ```
  ##############################################################################
  # section-name
  ##############################################################################
  ```
- Order functions/variables so dependencies are defined before use — a section
  may still run its top-level statements (e.g. `variables`) after `functions`,
  since function *definitions* don't execute at parse time.

## Subsections (functions)

- Create a function when a sequence of commands has a distinct responsibility,
  is reused, or benefits from isolated arguments and local variables; keep
  trivial one-off commands inline.
- Each function inside a section gets a single-line, 78-char title: `# name`
  followed by `#` padding to column 78 (no separate hash lines above/below):
  ```
  # push ######################################################################
  ```
- Immediately followed by a comment block, list-only, no prose:
  - `Actions:` — required, bullet list of what it does (imperative, terse)
  - `Notes:` — optional, only non-obvious caveats/invariants (idempotency,
    safety, why-not-obvious-alternative). Omit if nothing non-obvious to say.
  - `Usage:` — required, one or more literal call examples showing real
    argument values; this is also where arguments are documented.
- No blank line between the title/comment block and the function definition.

## Naming

- Function names: snake_case (`nix_push`).
- Internal scratch vars inside a function: `local`, leading underscore
  (`local _label`, `local _raw`).

## Conventions

- `die MESSAGE` helper for all fatal errors — never bare `exit 1` or raw
  `echo >&2; exit`.
- Quote all variable expansions; prefer `[[ ... ]]` over `[ ... ]` (bash test).
- Prefer `$(...)` over backticks.
- Declare function-local variables with `local` (or `local -a`/`local -A` for
  arrays/maps) instead of leaking globals. Combine a declaration with a
  literal or parameter-expansion assignment (`local _name="$_raw"`). Keep a
  command substitution on a separate assignment when its exit status matters:
  `local _path; _path=$(command) || die "command failed"`. When its status is
  explicitly irrelevant, combining is allowed (`local _refs=$(grep -c X file || true)`).
  `local _path=$(...)` otherwise masks the substitution's status because `local`
  succeeds.
- Run `shellcheck SCRIPT...` after Bash edits; fix warnings or add a narrowly
  scoped directive with a load-bearing justification.
- Inline comments inside a function body are for load-bearing/non-obvious
  lines only (e.g. why a sed rewrite exists) — don't restate what the code
  already says.
- Keep comments condensed and context-aware for an experienced reader: no
  duplication between title, Actions, Notes and Usage.

## Example

```bash
#!/usr/bin/env bash
# example.sh — fetch a remote resource and cache it locally.
# Usage:
#   ./example.sh <URL>
#
# Env optional:
#   CACHE_DIR — directory to store cached downloads (default: /tmp/cache)
#
# Functions:
#   die     MESSAGE  echo MESSAGE to stderr, exit 1
#   fetch   URL       download URL, cache it, echo the local path
set -euo pipefail

##############################################################################
# functions
##############################################################################

# die #######################################################################
# Actions:
# - echo "[Error] MESSAGE" (red) to stderr
# - exit 1
# Usage:
#   die "URL not set"
die() { printf '\033[31m[Error]\033[0m %s\n' "$*" >&2; exit 1; }

# fetch ######################################################################
# Actions:
# - download URL into CACHE_DIR, named after its sha256
# - echo the local path
# Notes:
# - idempotent: skips the download if the cached file already exists
# Usage:
#   path=$(fetch "https://example.com/file.tar.gz")
fetch() {
    local _url=$1
    local _name
    _name=$(sha256sum <<< "$_url" | cut -d' ' -f1)
    local _dest="$CACHE_DIR/$_name"

    [[ -f "$_dest" ]] || curl -fsSL -o "$_dest" "$_url" || die "download failed: $_url"
    echo "$_dest"
}

##############################################################################
# variables
##############################################################################

CACHE_DIR=${CACHE_DIR:-/tmp/cache}
mkdir -p "$CACHE_DIR"

##############################################################################
# arg parsing
##############################################################################

(( $# >= 1 )) || die "usage: $0 <URL>"
URL=$1

##############################################################################
# main
##############################################################################

fetch "$URL"
```

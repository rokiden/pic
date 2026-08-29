---
name: git-workflow
description: Git workflow conventions — branch naming, commit message prefixes and rules, and safe commit/push behavior. Load this before your first modifying git command in a session (git checkout, git commit, git push, git rebase, git merge, etc.) to ensure correct branch naming and commit formatting. Never guess or use default Git formatting.
---

# Git Workflow Guide — Coding Agent Instructions

## No Unprompted Stage, Commit, Push
**DO NOT stage, commit, or push unless the user explicitly asks you to.**
Creating branches (`git checkout -b`) is allowed if needed for the task, but commits and pushes require explicit permission. If in doubt, ask the user before staging, committing, or pushing.

## Branch Naming

When creating a new branch, use the following convention:

```
<PREFIX>/<TASK-ID>_<TASK-TITLE>
```

- **PREFIX** — one of: `feat`, `fix`, `refact`, `doc`, `test`, `other`
- **TASK-ID** — uppercase task identifier with dashes (e.g., `FPG-123`)
- **TASK-TITLE** — lowercase, dash-separated description

Examples:
- `feat/FPG-123_write-style-guide`
- `fix/rrc-coeff-width`
- `refact/xcelium-test`
- `doc/add-readme`
- `test/qam-tests`

If there is no task ID, use the shortened form: `<PREFIX>/<TASK-TITLE>` (e.g., `feat/add-correlator`).

---

## Commit Message Prefixes

Prefix every commit subject line with one of the following types:

| Prefix     | Purpose                              | Example                                      |
|------------|--------------------------------------|----------------------------------------------|
| `feat`     | New functionality                    | `feat: add correlator core`                  |
| `fix`      | Bug fix                              | `fix: rrc filter coeff width`                |
| `docs`     | Documentation-only changes           | `docs: add regmap markdown`                  |
| `refact`   | Code refactoring (no behavior change)| `refact: moved functionality into classes`   |
| `test`     | Adding or modifying tests            | `test: add cocotb tests for QAM mapper`      |
| `chore`    | Routine / maintenance tasks          | `chore: update .gitignore`                   |
| `build`    | Build or deployment changes          | `build: add make for autobuild`              |
| `perf`     | Performance improvements             | `perf: reduced number of multipliers`        |
| `revert`   | Reverting changes                    | `revert: undo PCIEx8 to PCIEx4`              |
| `wip`      | Work in progress (temporary commits) | `wip: end of working day`                    |
| `init`     | Project/module initialization        | `init: init repository`                      |
| `chpick`   | Cherry-picked changes                | `chpick: changes from commit 0123ab added`   |
| `update`   | Dependency / submodule updates       | `update: pyproject dependencies updated`     |

### Module Scope Label

When a change targets a specific module, add the module name as a scope label in parentheses immediately after the prefix:

```
<_prefix>(<module-name>): <module-changes>
```

- The scope identifies which module/component the change affects, keeping commit subjects readable and filterable by module.
- Use a short, stable module identifier (e.g., `correlator`, `rrc`, `qam-mapper`, `regmap`).
- Use the bare prefix (`<prefix>: ...`) when a change spans multiple modules or is not module-specific.

Examples:
- `feat(correlator): add pipelined accumulator`
- `fix(rrc): correct coefficient width`
- `refact(qam-mapper): split mapper into classes`
- `docs(regmap): add field descriptions`
- `test(cocotb): add QAM mapper testbench`

### Commit Rules

- Subject line: **maximum 100 characters**, start with the prefix (optionally scoped) followed by a colon and a space.
- One commit = one logical change.
- Use `wip` prefix for intermediate/temporary commits; clean them up before merging.
- Do **not** use `--amend` on already-pushed commits.
- If `user.name`/`user.email` are not configured (locally or globally), do **not** guess or invent an identity. Reuse the author of the previous commit via `--author="$(git log -1 --pretty=format:'%an <%ae>')"`, e.g.:
  ```bash
  git commit --author="$(git log -1 --pretty=format:'%an <%ae>')" -m "feat(correlator): ..."
  ```

---

## Quick Reference

```bash
# Create & push a new branch (only if asked)
git checkout -b feat/FPG-123_write-style-guide
git push -u origin feat/FPG-123_write-style-guide

# Example commits (only if asked)
git commit -m "feat(correlator): implement pipelined core"
git commit -m "docs(regmap): add field descriptions"

# Update branch with latest dev before MR (only if asked)
git fetch origin
git rebase origin/dev
```

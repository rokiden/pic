# Git Workflow Guide — Coding Agent Instructions

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

### Pushing branches

Always push new branches after creation to keep GitLab in sync.

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

### Commit Rules

- Subject line: **maximum 50 characters**, start with the prefix followed by a colon and a space.
- One commit = one logical change.
- Use `wip` prefix for intermediate/temporary commits; clean them up before merging.
- Do **not** use `--amend` on already-pushed commits.

---

## Quick Reference

```bash
# Create & push a new branch
git checkout -b feat/FPG-123_write-style-guide
git push -u origin feat/FPG-123_write-style-guide

# Example commits
git commit -m "feat: implement correlator core"
git commit -m "feat: add documentation for correlator"

# Update branch with latest dev before MR
git fetch origin
git rebase origin/dev
```

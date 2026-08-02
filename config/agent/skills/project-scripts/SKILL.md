---
name: project-scripts
description: Save, discover, update, and reuse useful commands/scripts in the project's .pi/scripts directory with a markdown index for quick discovery. Use when writing or running reusable commands, complex pipes, jq filters, find expressions, data transformations, batch file operations, or API interactions that may recur.
---

# project-scripts: Script Reuse Workflow

You have a script reuse system at `.pi/scripts/` (relative to the project root). Use it to save, discover, and reuse useful commands across your work on the project.

## Saving Scripts

Whenever you write or run a command that is **useful, reusable, or might be needed again**:

1. **Choose a meaningful name** — descriptive lowercase with kebab-case (e.g., `find-unused-images`, `generate-mock-data`, `batch-rename-files`)
2. **Pick the right extension** — auto-detect: `.sh` for bash, `.py` for python, `.js` for node, `.rb` for ruby, etc.
3. **Write it to `.pi/scripts/<name>`** (extension inferred)
4. **Update the index** (a markdown file, not JSON — easier to read and parse):

Create or append to `.pi/scripts/.index.md`:

```
| Name | Description | Last Modified |
|------|-------------|---------------|
| `<name>` | `<short description>` | `<date>` |
```

If the file already exists, insert a new row (keep it sorted by name so it stays readable). If `.index.md` doesn't exist yet, create it with a header row + data.

## Reusing Scripts

Before writing something new:

1. **Check the index first:** `cat .pi/scripts/.index.md` — scan descriptions for matches
2. **If found**, just run it: `bash .pi/scripts/<name>` or whatever interpreter it needs
3. **If not found**, write a new script and add to the index

## Auto-Save Triggers

Save a script when ANY of these apply:

- You use a command/pattern **2+ times** in the same session
- A command involves **complex pipes, jq filters, find expressions, or regex** that would be painful to retype
- You're working with **data transformations**, **file batch operations**, or **API interactions** that might recur
- The user explicitly asks you to "save this"

## Naming Convention

| Example | When to use |
|---------|-------------|
| `find-unused-images` | File discovery tasks |
| `generate-mock-data` | Data generation |
| `batch-rename-videos` | File batch operations |
| `extract-field-from-json` | Data extraction / jq pipelines |
| `check-service-health` | Service/API health checks |

Avoid generic names like `script.sh`, `test.py`, or `mycommand`. Always pick something that tells you what it does just from the name.

## Updating Scripts

Scripts are meant to be **improved over time**, not just written and forgotten:

- If a saved script lacks arguments or flexibility, **update it** (e.g., add `-h help`, accept input via args/env vars, support multiple cases)
- If you need the same script for slightly different purposes, extend it rather than creating a new one
- Update the index description if the script's capabilities changed significantly
- Add usage examples to the script as comments when they grow beyond trivial

Example: `generate-mock-data` might start as just generating 10 records, but later get updated to accept `--count` and `--format json|csv` arguments.

## Quick Reference

```bash
# List all saved scripts (via index)
cat .pi/scripts/.index.md

# Check what's in the scripts dir
ls -la .pi/scripts/

# Run a saved script
bash .pi/scripts/<name>
python3 .pi/scripts/<name>.py
node .pi/scripts/<name>.js
```

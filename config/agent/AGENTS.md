# Global Instructions

Obey the following constraints strictly.

## Communication Guidelines
- Be direct and consice
- No filler words
- Prefer numbered and bullet lists
- Don’t elaborate unless requested
- Don’t be redundant or repetitive

## Container Environment & Package Management
- You are jailed into Alpine Linux Container. 
- If a required tool is missing, install it with `apk add <package>` (without `--no-cache`) so downloaded packages can be cached. The container has a persistent APK cache. Avoid clearing the cache.
- Man pages are missing by default. If you need a man page for package, you MUST install `<package>-doc` first. 

## File System & Workspace Hygiene
- **Workspace:** Keep the current working directory strictly for project files.
- **Scratch Space:** ALL temporary files, downloads, or intermediate processing steps MUST occur in `/tmp`.
- **Edits:** Respect existing content and prefer minimal changes to it.
- **User Manual Edits:** Never revert or discard changes the user made. If unexpected changes look significant or unclear, ask before editing.

## Calculations
**NEVER do math in your head.** You MUST write and execute a short `python` script (e.g., `python -c "print(x * y)"`) or use `bash` (e.g., `$((x * y))`, `bc`, or `awk`) to compute all numbers.

## Harness
- Propose to the user improvements for unclear, incomplete, or incorrect skill or AGENTS.md rules.
- Use `todo` tool only if user exlicitly asked

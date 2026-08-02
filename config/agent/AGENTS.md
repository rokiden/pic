# Global Instructions

Obey the following constraints strictly.

##  Git Workflow
Read /root/.pi/agent/GIT.md **before your first modifying git command in a session** (e.g., `git checkout`, `git commit`, `git push`, `git rebase`, `git merge`, etc.) to ensure correct branch naming, commit conventions, and workflow rules. NEVER guess or use default Git formatting.

## Container Environment & Package Management
- You are jailed into Alpine Linux Container. 
- If a required tool is missing, install it using bash command `apk add <package>`. 
- Man pages are missing by default. If you need a man page for package, you MUST install `<package>-doc` first. 

## RTFM (No Guessing Protocol)
ALWAYS consult the documentation using this strict hierarchy before execution:
1. **Primary:** Run `man <command>`. To avoid context flooding, NEVER run raw man; ALWAYS pipe to search or read in chunks (e.g., man <command> | grep -A <chunk> "<topic>").
2. **Secondary:** Run `<command> --help`.
3. **Tertiary:** Search the web/online docs ONLY if local options fail.

## File System & Workspace Hygiene
- **Workspace:** Keep the current working directory strictly for project files. 
- **Scratch Space:** ALL temporary files, downloads, or intermediate processing steps MUST occur in `/tmp`. 

## Calculations
**NEVER do math in your head.** You MUST write and execute a short `python` script (e.g., `python -c "print(x * y)"`) or use `bash` (e.g., `$((x * y))`, `bc`, or `awk`) to compute all numbers.

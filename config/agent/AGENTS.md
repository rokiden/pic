# Global Instructions

You are an autonomous AI agent operating in an Alpine Linux container. Obey the following constraints strictly.

## 1. Git Workflow
*   **TRIGGER:** Before executing your first `git checkout -b` or `git commit` in a session.
*   **ACTION:** You MUST read `[git-workflow.md](./git-workflow.md)` to retrieve branch naming and commit message conventions. NEVER guess or use default Git formatting.

## 2. Container Environment & Package Management
*   **Environment:** Alpine Linux. Man pages are missing by default. 
*   **Installation:** If a required tool is missing, execute `apk add <package>`. 
*   **Documentation:** If you need a man page, you MUST install `<package>-doc` first. 

## 3. RTFM (No Guessing Protocol)
NEVER hallucinate or guess command-line flags. If you are not 100% certain of a command's syntax, you MUST verify it using this strict hierarchy before execution:
1.  **Primary:** Run `man <command>`. To avoid context flooding, NEVER run raw man; ALWAYS pipe to search or read in chunks (e.g., man <command> | grep -A <chunk> "<topic>").
2.  **Secondary:** Run `<command> --help`.
3.  **Tertiary:** Search the web/online docs ONLY if local options fail.
*If documentation is unavailable and you are unsure, pause and ask the user.*

## 4. File System & Workspace Hygiene
*   **Workspace:** Keep the current working directory strictly for project files. 
*   **Scratch Space:** ALL temporary files, downloads, or intermediate processing steps MUST occur in `/tmp`. 

## 5. Calculations
**NEVER do math in your head.** LLMs hallucinate calculations. You MUST write and execute a short `python` script (e.g., `python -c "print(x * y)"`) or use `bash` (e.g., `$((x * y))`, `bc`, or `awk`) to compute all numbers.


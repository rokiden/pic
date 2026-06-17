# pic (Pi Container)

A lightweight CLI wrapper and Podman environment for sandboxing the Pi coding agent.

## Setup & Installation

1. **Build the Image:**
   Run the following command in the directory containing the `Containerfile`:
   ```bash
   podman build -t pic:latest .
   ```

2. **Run the Agent:**
   Execute `pic` from any project directory. Each run creates a fresh container that self-destructs on exit. Pass arguments to forward them to `pi`:
   ```bash
   pic                     # Interactive session
   pic --help              # Forward args to pi
   ```

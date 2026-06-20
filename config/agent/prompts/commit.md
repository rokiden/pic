---
description: Review staged git changes and commit
---

Review the staged changes (`git diff --cached`). Focus on:

- **Correctness:** logic errors, edge cases, off-by-one mistakes
- **Security:** injection vectors, secret exposure, permission issues
- **Error handling:** missing catches, silent failures, unhandled rejections
- **Code quality:** readability, naming, duplication, complexity
- **Tests:** relevant test coverage for the changes

After reviewing, compose a concise commit message in conventional commits format.

Commit **only the already-staged** changes on the current branch. Do not stage additional files, switch, or create branches unless explicitly asked.

If there are no serious issues, commit staged changes, else recommend fixes before committing.

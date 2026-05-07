---
name: neural.archive
description: "[Neural SDD] Move completed features from wip to archive. Part of the neural plugin — invoke via /neural.archive"
keep-coding-instructions: true
---

# Neural Archive

Move completed features from `.neural/wip/` to `.neural/archive/`.

## Procedure

1. **Check for active features.** List all directories in `.neural/wip/`. If none exist, report: "No active features in `.neural/wip/`. Nothing to archive." and stop.

2. **Select the feature to archive.**
   - If an argument was provided, use it as the feature name. Verify it exists in `.neural/wip/<name>/`. If not found, list available features and ask the user to pick one.
   - If multiple features exist and no argument was given, list them and ask: "Which feature do you want to archive?"
   - If only one feature exists, confirm: "Archive `<name>`? (y/n)"

3. **Move the feature directory.** Run:
   ```bash
   mkdir -p .neural/archive/
   mv .neural/wip/<name>/ .neural/archive/<name>/
   ```

4. **Confirm completion.** Report:
   ```
   Feature '<name>' archived. .neural/wip/<name>/ → .neural/archive/<name>/
   ```

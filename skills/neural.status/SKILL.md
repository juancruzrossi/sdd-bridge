---
name: neural.status
description: "[Neural SDD] Show progress of all features in .neural/wip/ and suggest next steps. Part of the neural plugin — invoke via /neural.status"
keep-coding-instructions: true
---

# Neural Status

Show progress of all active Neural features and suggest next steps.

## Procedure

1. **Check for the `.neural/wip/` directory.** If it does not exist or is empty, report: "No active Neural features. Start one with `/neural.interview`" and continue to step 5.

2. **List all feature directories in `.neural/wip/`.** For each feature directory, check which of these files exist:
   - `BRIEF.md` — created by `/neural.interview`
   - `PLAN.md` — created by `/neural.plan`
   - `REVIEW.md` — created by `/neural.review`

3. **Determine the next step for each feature.** Apply this logic:
   - Missing `BRIEF.md` → Next: `/neural.interview`
   - Has `BRIEF.md`, missing `PLAN.md` → Next: `/neural.plan`
   - Has `BRIEF.md` and `PLAN.md`, missing `REVIEW.md` → Next: `/neural.execute` or `/neural.review`
   - Has all three → Next: `/neural.archive`

4. **Display the status table.** Format output exactly like this:
   ```
   Neural SDD Status

   Active features:
     <feature-name>:
       ✓ BRIEF.md (interview complete)
       ✓ PLAN.md (plan complete)
       ✗ REVIEW.md
       → Next: /neural.execute or /neural.review

     <feature-name>:
       ✓ BRIEF.md (interview complete)
       ✗ PLAN.md
       ✗ REVIEW.md
       → Next: /neural.plan
   ```

5. **Check `.neural/archive/`.** If it exists, count the subdirectories and report: `Archived: <N> features`. If it does not exist, report: `Archived: 0 features`.

---
name: neural.debug
description: "[Neural SDD] Systematic root-cause investigation for bugs and failures. Part of the neural plugin — invoke via /neural.debug"
keep-coding-instructions: true
---

# Neural Debug

Systematic root-cause investigation for bugs and failures. Five phases: context, investigate, analyze, hypothesize, implement.

**Iron Law: NO fixes without root cause. Do not patch symptoms.**

## Procedure

### Phase 1: Context Gathering

1. **Read the bug description from the arguments.** If no description was provided, ask: "What bug or error are you seeing? Paste the error message, describe the behavior, or point me to the failing code."

2. **Check for Neural feature context.** Look for `.neural/wip/` directories. If the bug relates to an active feature, read its `BRIEF.md` and `PLAN.md` for architectural context and intended behavior.

### Phase 2: INVESTIGATE

3. **Gather evidence.** Read error messages, logs, and stack traces. Identify the exact trigger and failure point. Reproduce the issue if possible.

4. **Map the affected files.** List every file mentioned in the error or stack trace. Read each one.

5. **Instrument component boundaries.** For systems with multiple components (API → service → database, frontend → API → backend), add diagnostic logging at each boundary BEFORE reasoning about the cause:
   - Log what data enters each component
   - Log what data exits each component
   - Check environment variables and configuration propagation at each layer
   - Run once with instrumentation to gather concrete evidence of WHERE the data goes wrong
   
   This is faster and more reliable than theorizing about where the bug might be. Let the logs tell you.

6. **Do NOT guess at causes yet.** Only collect facts. Note what you observe without interpretation.

### Phase 3: ANALYZE

7. **Trace the code path.** Follow execution from the trigger point to the failure. Identify every function call, data transformation, and conditional branch along the way.

8. **Trace backward from the failure.** Start at the exact point of failure and ask: "What called this function with this value?" Follow the chain backward through the call stack until you find where the incorrect data originated. This is often more effective than forward tracing because it starts from certainty (the error) and works toward the unknown (the source).

   If you can't trace manually, add `new Error().stack` or equivalent stack trace capture at the failure point to see the full call chain.

9. **Identify the broken component.** Determine which specific component, function, or data flow is responsible for the failure.

10. **Document the chain of causation.** Write down: trigger → intermediate steps → failure. Be precise.

### Phase 4: HYPOTHESIZE

11. **Form 2-3 hypotheses ranked by likelihood.** For each hypothesis:
   - State what the root cause would be
   - Describe what evidence would confirm it
   - Describe what evidence would refute it

12. **Test each hypothesis.** Run targeted checks — read specific code, run specific commands, add diagnostic output. Confirm or eliminate each hypothesis.

13. **Compare with working code.** Search the codebase for similar functionality that works correctly. Compare the working version against the broken one — the difference often reveals the root cause faster than reasoning from scratch.

14. **Recognize architectural problems.** If 3 or more hypotheses have been refuted, or each fix reveals a new problem in a different location, STOP. This pattern usually signals a structural issue, not a point bug. Report to the user: "This appears to be an architectural problem rather than an isolated bug. The repeated failures suggest [pattern]. Recommend discussing the approach before attempting more fixes."

15. **Identify the root cause.** One hypothesis should survive testing. If none do, return to Phase 2 with new information.

### Phase 5: IMPLEMENT

16. **Fix the root cause.** Make the minimal change that addresses the actual problem, not its symptoms.

17. **Verify the fix.** Run the reproduction steps from Phase 2. Confirm the error no longer occurs.

18. **Run tests.** Execute the project's test suite to confirm no regressions.

19. **Commit the fix (if git is initialized).** Run `git rev-parse --is-inside-work-tree 2>/dev/null` — if the project has git, make an atomic commit describing the root cause and the fix. If no git, skip this step.

20. **Suggest next step.** Report: "Fixed! Run `/neural.review` to verify the full feature still works."

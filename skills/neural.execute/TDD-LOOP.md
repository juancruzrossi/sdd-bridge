# TDD Loop — Vertical Slicing

## The core principle

Tests verify **behavior through public interfaces**, not implementation details. Implementations can change entirely; tests should not. A good test reads like a specification — "user can checkout with a valid cart" tells you exactly what capability the system has.

## Anti-pattern: horizontal slicing

**Do not write all tests first, then all the code.** Treating RED as "write every test" and GREEN as "write every implementation" produces brittle tests:

- Tests written in bulk describe **imagined** behavior, not actual behavior.
- They drift toward asserting **shape** (signatures, data structures) instead of user-facing outcomes.
- They become insensitive to real changes — passing when behavior breaks, failing when behavior is fine.
- You commit to a test design before learning what the code teaches you.

```
WRONG (horizontal):
  RED:   test1, test2, test3, test4, test5
  GREEN: impl1, impl2, impl3, impl4, impl5

RIGHT (vertical):
  RED→GREEN: test1 → impl1
  RED→GREEN: test2 → impl2
  RED→GREEN: test3 → impl3
  ...
```

Each test responds to what you learned from the previous cycle. Because you just wrote the code, you know exactly what behavior matters and how to verify it.

## The loop, in three beats

### 1. Tracer bullet (first behavior of the task)

Pick the behavior whose existence proves the path works end-to-end. Write **one** test. Watch it fail for the right reason (not a typo, not a missing import — the actual assertion fails). Write the minimum code to pass it. Watch it go green.

This is your tracer bullet. After it lands, the rest of the task is a march of similar cycles along the behavior list.

### 2. Incremental cycles (remaining behaviors)

For each remaining behavior in the task:

```
RED:   add one test → fails
GREEN: minimum code to pass → passes
```

Rules:

- One test at a time.
- Only enough code to pass the current test. Do not anticipate the next test.
- Tests describe observable behavior, not internal structure.
- Run the relevant tests after every change. Trust nothing.

### 3. Refactor (only on green)

After every behavior in the task is green, look for refactor candidates:

- Extract duplication.
- Deepen modules — push complexity behind small interfaces.
- Apply SOLID where it falls out naturally, not as a target.
- Reconsider what the new code reveals about existing code.

Re-run tests after each refactor step. **Never refactor while RED.** Get to green first, always.

## Checklist per cycle

```
[ ] Test describes behavior, not implementation
[ ] Test uses the public interface only
[ ] Test would survive an internal refactor
[ ] Code is the minimum to pass this one test
[ ] No speculative features added
```

If any box is unchecked, the cycle is not done — adjust before moving on.

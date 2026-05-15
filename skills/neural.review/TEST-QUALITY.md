# Test Quality Audit

A green test suite is not proof of correctness — it is proof that whatever the tests assert is currently true. The audit below catches the failure modes that let bugs survive a green suite.

## 1. Disabled tests linked to feature requirements

Grep for skip markers:

- `it.skip`, `describe.skip`, `xit`, `xdescribe`
- `test.skip`, `test.todo`
- `@pytest.mark.skip`, `@pytest.mark.xfail`
- `@Disabled`, `@Ignore`
- `t.Skip(` (Go)

Any disabled test connected to a feature requirement means that requirement is **not** currently being verified. Surface it as a Warning at minimum, Blocking if it sits on a critical path.

## 2. Weak assertions on critical behaviors

Classify assertions. These prove only that something exists, not that it works:

- `toBeDefined()`, `toBeTruthy()`, `assertNotNull`
- Asserting a function returns "any object" without checking fields
- Asserting an array is non-empty without checking contents

If the behavior demands a specific outcome, the test must assert that specific outcome. Weak assertions on critical behaviors are gaps.

## 3. Tests coupled to implementation

These tests will pass even after the system breaks, or fail when it still works. Patterns to flag:

- **Mocks of internal collaborators.** Mocking your own classes, modules, or functions inside the same bounded context. Mock only true system boundaries.
- **Asserting on call counts or call order.** `toHaveBeenCalledWith(...)` for an internal function describes how rather than what.
- **Bypassing the interface to verify.** Querying the DB directly after calling a service, when the service exposes a getter the test could use.
- **Test name describes how, not what.** Names like `"calls paymentService.process"` give it away.

These tests are technically green but contribute negative value — they fight every refactor.

## 4. Circular tests

A circular test generates its expected value by running the system under test, then compares the system to itself.

```js
// Proves nothing
expect(calculate(x)).toBe(calculate(x));

// Also circular — fixture is produced by the same code path being tested
const expected = serialize(parse(input));
expect(serialize(parse(input))).toEqual(expected);
```

These prove consistency, not correctness. If you find them, the behavior they claim to verify is actually unverified.

## Reporting

For each finding, record:

- The test file and case name.
- The feature requirement or behavior it was supposed to cover (if any).
- Recommended action: enable, strengthen, decouple, or replace with a real assertion.

Test-quality findings are at least Warnings. When they sit on a behavior that the feature explicitly promised, they are Blocking.

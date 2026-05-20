# Good and Bad Tests

The single question to ask before writing a test: **would this test still pass if I rewrote the internals but kept the behavior?** If no, the test is coupled to implementation and will fight every future refactor.

## Good tests — integration-style through public interfaces

```typescript
// GOOD: asserts observable outcome
test("user can checkout with a valid cart", async () => {
  const cart = createCart();
  cart.add(product);
  const result = await checkout(cart, paymentMethod);
  expect(result.status).toBe("confirmed");
});
```

Characteristics:

- Asserts a fact a caller or user actually cares about.
- Uses the public API only — no reaching into internals.
- Survives internal refactors.
- Describes **what**, not **how**.
- One logical assertion per test. If you need two, you usually have two tests.

## Bad tests — coupled to internals

```typescript
// BAD: asserts a private collaboration
test("checkout calls paymentService.process", async () => {
  const mockPayment = jest.mock(paymentService);
  await checkout(cart, payment);
  expect(mockPayment.process).toHaveBeenCalledWith(cart.total);
});
```

Red flags:

- Mocking internal collaborators.
- Asserting on call counts or call order.
- Testing private methods directly.
- Verifying state by bypassing the interface (e.g., raw DB queries).
- The test name describes **how**, not **what**.
- The test breaks when you refactor but behavior is unchanged.

## Verify through the interface, not around it

```typescript
// BAD: bypasses the interface to verify
test("createUser saves to database", async () => {
  await createUser({ name: "Alice" });
  const row = await db.query("SELECT * FROM users WHERE name = ?", ["Alice"]);
  expect(row).toBeDefined();
});

// GOOD: verifies through the interface
test("createUser makes the user retrievable", async () => {
  const user = await createUser({ name: "Alice" });
  const retrieved = await getUser(user.id);
  expect(retrieved.name).toBe("Alice");
});
```

The good version still works if the storage layer is rewritten to use a different table, key-value store, or remote service. The bad version breaks the moment internals change — even though behavior is identical.

## When in doubt

Ask: "If a future contributor renames a private function and keeps behavior identical, will my test still pass?" If you cannot say yes, the test is coupled to the wrong thing.

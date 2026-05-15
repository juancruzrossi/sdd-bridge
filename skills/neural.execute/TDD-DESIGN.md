# Design for Testability and Depth

The shape of the code drives the shape of the tests. If tests feel hard to write or hard to keep stable, the design is usually the problem.

## Deep modules

A **deep module** has a small interface and a lot of implementation behind it.

```
┌─────────────────────┐
│   Small Interface   │  few methods, simple params
├─────────────────────┤
│                     │
│ Deep Implementation │  complex logic hidden inside
│                     │
└─────────────────────┘
```

A **shallow module** has a large interface and very little implementation — it just passes calls through. Avoid these; they add surface area without adding leverage.

When designing or refactoring an interface, ask:

- Can I reduce the number of methods?
- Can I simplify the parameters?
- Can I hide more complexity inside?

Tests against deep modules stay stable because the surface is small. Tests against shallow modules churn because every internal change leaks through.

## Interface design for testability

### 1. Accept dependencies, do not create them

```typescript
// Testable
function processOrder(order, paymentGateway) { /* ... */ }

// Hard to test
function processOrder(order) {
  const gateway = new StripeGateway();
}
```

### 2. Return results, do not produce side effects

```typescript
// Testable — pure, returns a value
function calculateDiscount(cart): Discount { /* ... */ }

// Hard to test — mutates in place
function applyDiscount(cart): void {
  cart.total -= discount;
}
```

### 3. Keep the surface small

- Fewer methods → fewer tests required for full coverage.
- Fewer parameters → simpler setup per test.
- Less optionality → fewer edge cases to invent assertions for.

## Refactor candidates (after green)

Once the task is green, scan for these and address what is worth addressing:

- **Duplication** → extract function, class, or value object.
- **Long methods** → break into private helpers. Keep tests on the public interface.
- **Shallow modules** → combine or deepen.
- **Feature envy** → move logic to where the data lives.
- **Primitive obsession** → introduce a value object.
- **Existing code the new code exposes as awkward** → consider whether the new work justifies a small cleanup.

Re-run the tests after each refactor step. If a test breaks, the refactor changed behavior — revert and try again with a smaller step.

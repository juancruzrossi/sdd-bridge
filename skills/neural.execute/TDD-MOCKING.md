# When to Mock

Mock at **system boundaries only** — the seams where your code meets something it does not own.

## Mock these

- External APIs (payments, email, search, etc.).
- Databases when a real test DB is unavailable. Prefer a real test DB when feasible.
- Time and randomness (`Date.now`, `Math.random`).
- Filesystem in narrow cases.

## Do not mock these

- Your own classes, modules, or functions.
- Internal collaborators inside the same bounded context.
- Anything you control and could test directly.

Mocking internal collaborators is the fastest way to write tests that lie. They couple to call shape rather than outcome, so refactors break them even when the system still works correctly.

## Designing for mockability

When you do mock at a boundary, design the boundary so the mock is trivial.

### 1. Pass dependencies in — do not construct them inside

```typescript
// Easy to mock
function processPayment(order, paymentClient) {
  return paymentClient.charge(order.total);
}

// Hard to mock
function processPayment(order) {
  const client = new StripeClient(process.env.STRIPE_KEY);
  return client.charge(order.total);
}
```

Dependency injection at boundaries keeps the test setup boring and the production wiring explicit.

### 2. Prefer SDK-style interfaces over generic fetchers

Specific functions per operation beat one generic function with conditional logic.

```typescript
// GOOD: each function is independently mockable
const api = {
  getUser: (id) => fetch(`/users/${id}`),
  getOrders: (userId) => fetch(`/users/${userId}/orders`),
  createOrder: (data) => fetch("/orders", { method: "POST", body: data }),
};

// BAD: mocking requires branching inside the mock
const api = {
  fetch: (endpoint, options) => fetch(endpoint, options),
};
```

The SDK shape gives:

- Each mock returns one specific shape.
- No `if (endpoint === "...")` logic in test setup.
- Clear visibility into which endpoints a test exercises.
- Type safety per endpoint.

# Add a "Browse products" CTA to the empty orders page

When a user has no orders yet, `/orders` shows the muted text
`No orders yet.` but offers no path forward. Add a call-to-action
button or link that takes the user to the catalog so they can
actually place a first order.

## Bug location

`app/pages/OrdersPage.cl.jac`. The empty-state block currently
contains only a single `<p>`. There is no link element.

## Expected behaviour

When `len(orders) == 0`, render an empty-state block that contains:

- The existing copy (or equivalent), e.g. `No orders yet.`
- A `<Link to="/">` (imported from `@jac/runtime`) labelled to the
  effect of `Browse products`.

The non-empty branch (the order list and cancel buttons) must
continue to render as today.

## How to verify

```bash
cd suite/agent/medium/ecommerce/jaclang/app
jac check main.jac
jac start main.jac --port 9000
```

Open <http://localhost:9000/orders> with a brand-new user (no
seeded orders) and confirm the CTA renders.

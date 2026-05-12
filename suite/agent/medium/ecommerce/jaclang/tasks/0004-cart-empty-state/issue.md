# Add empty-cart state to /cart page

When a user opens `/cart` and their cart is empty, the page renders a
blank area with no message and no way to navigate back to the catalog.
Add an empty-state block that tells the user the cart is empty and
gives them a button or link to browse products.

## Bug location

`app/pages/CartPage.cl.jac`. The page currently renders only the
"items + total" block, gated on `len(items) > 0`. The complementary
`len(items) == 0` block is missing.

## Expected behaviour

When `len(items) == 0`, the page must show:

- A short message containing the phrase `cart is empty` (for example,
  "Your cart is empty.").
- A `<Link to="/">` (or equivalent navigation) labelled to the effect
  of `Browse products`.

The non-empty state must continue to render the items, total, and
checkout button as today.

## How to verify

```bash
cd suite/agent/medium/ecommerce/jaclang/app
jac check main.jac
jac start main.jac --port 9000
```

Open <http://localhost:9000/cart> with a brand new user (one whose
cart has no items) and confirm the empty-state UI renders.

The grading oracle scans the source for the expected tokens, so
your phrasing can vary as long as the patterns are present.

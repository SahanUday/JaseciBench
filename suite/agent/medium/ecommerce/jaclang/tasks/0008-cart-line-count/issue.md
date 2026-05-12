# Surface cart line-item count on the /cart page

The `/cart` page header reads "Shopping Cart" with no indication of how
many items are in the cart. The server already collects the data but
does not surface it in the response, and the page does not render it.
Add a `count` field to `get_cart` and render it in the page header as
`Shopping Cart (N items)`.

## Bug location

Two changes are required:

1. `app/services/cart.sv.jac`, the `get_cart` function. The returned
   dict has `items` and `total` but no `count`.
2. `app/pages/CartPage.cl.jac`, the page header. The header is a static
   "Shopping Cart" string with no item count.

## Expected behaviour

### Server (`get_cart`)

Add a `"count"` key whose value is `len(items)` (i.e. the number of
distinct cart-item rows for the user). Keep `items` and `total` as
they are.

### Client (`CartPage`)

Render the page header as `"Shopping Cart (" + str(count) + " items)"`,
where `count` comes from the server response. Empty cart should show
`"Shopping Cart (0 items)"`.

## How to verify

```bash
cd suite/agent/medium/ecommerce/jaclang/app
jac check main.jac
jac test tests/baseline.jac
```

Backend smoke:

```bash
curl -s -X POST http://localhost:9000/function/get_cart \
    -H "Content-Type: application/json" -d '{"user_id":"user_001"}' \
    | jq '.data.result.count'
# expected: 1 (alice has the seeded coffee maker)
```

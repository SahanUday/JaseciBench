# Add shipping line + grand total to the cart

The cart total only shows the line subtotal sum. There is no shipping
fee, no separate display of subtotal, and no `grand_total = subtotal + shipping`.
Real customers want to see what they will actually be charged.

## Bug location

Two changes:

1. `app/services/cart.sv.jac`, `get_cart`. Returned dict has only
   `items`, `total`, `count`. Add shipping and grand total.
2. `app/pages/CartPage.cl.jac`. Total block shows a single "Total" line.

## Expected behaviour

### Server (`get_cart`)

Add two new keys:

- `"shipping"`: `5.99` if `total > 0.0`, else `0.0`.
- `"grand_total"`: `total + shipping` rounded to two decimals.

### Client (`CartPage`)

Render three lines in the totals block:

- Subtotal: `"$" + str(cart["total"])`
- Shipping: `"$" + str(cart["shipping"])`
- Grand total: `"$" + str(cart["grand_total"])` (large bold)

## How to verify

Backend:

```bash
curl -s -X POST http://localhost:9000/function/get_cart \
    -H "Content-Type: application/json" -d '{"user_id":"user_001"}' \
    | jq '.data.result | {total, shipping, grand_total}'
# expected: total=79.99, shipping=5.99, grand_total=85.98
```

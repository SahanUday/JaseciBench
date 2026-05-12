# Enforce a stock ceiling across cumulative add-to-cart calls

`add_to_cart(user_id, variant_id, quantity)` rejects requests where
`quantity > stock_qty`, but it does **not** account for what the user
already has in the cart. A user with 5 of `var_001` (stock 10) who
adds 8 more lands at 13 in cart, oversold against the variant.

## Bug location

`app/services/cart.sv.jac`, the `add_to_cart` function. The stock
check compares only against the incoming `quantity`, not against the
existing cart-line plus the incoming `quantity`.

## Expected behaviour

- Look up any existing `CartItem` for `(user_id, variant_id)` and read
  its current `quantity` (default to 0 if none).
- Reject with `{"error": "Insufficient stock", "status": 400}` when
  `existing_qty + quantity > variant.stock_qty`.
- Otherwise: if a line exists, increment its quantity; if not, create
  a new line.
- The 404 (variant not found) and quantity<1 guards must keep working.

## How to verify

```bash
cd suite/agent/medium/ecommerce/jaclang/app
jac check main.jac
jac test tests/baseline.jac
```

Backend smoke (assumes var_001 stock = 50):

```bash
# add 30, OK
curl -s -X POST http://localhost:9000/function/add_to_cart \
    -H "Content-Type: application/json" \
    -d '{"user_id":"user_x","variant_id":"var_001","quantity":30}'
# add 25 more, must error (30 + 25 = 55 > 50)
curl -s -X POST http://localhost:9000/function/add_to_cart \
    -H "Content-Type: application/json" \
    -d '{"user_id":"user_x","variant_id":"var_001","quantity":25}'
```

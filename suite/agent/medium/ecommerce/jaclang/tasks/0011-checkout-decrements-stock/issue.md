# Decrement variant stock on successful checkout

The `checkout` endpoint creates the order, the order items, and the
payment, then clears the cart, but it never decrements the variant
stock. After ten checkouts the same variant is still listed at its
original `stock_qty`. This corrupts inventory and lets the system
oversell.

## Bug location

`app/services/cart.sv.jac`, the `checkout` function. Inside the
per-line `for idx in range(len(resolved_variants))` loop, the
`v.stock_qty = v.stock_qty - qty` line is missing.

## Expected behaviour

For every cart item being checked out, decrement
`variant.stock_qty` by the line's quantity. The pre-validation step
(which already errors out on insufficient stock) means stock will
never go negative through this path.

## Example

Variant `var_001` starts with `stock_qty = 50`. After a checkout that
includes 3 of `var_001`, `get_product("prod_001")` should report
`var_001.stock_qty = 47`.

## How to verify

```bash
cd suite/agent/medium/ecommerce/jaclang/app
jac check main.jac
jac test tests/baseline.jac
```

All 16 baseline tests must pass after your fix.

# Reject double-returns on the same order item

The `return_items(order_id, item_ids, payment_method_id)` endpoint
processes returns idempotently-by-id, meaning a caller can submit the
same `oi_id` twice (or two requests in a row for the same item) and
get refunded twice. Inventory is also restored twice, leaking stock.

## Bug location

`app/services/orders.sv.jac`, the `return_items` function. Inside the
validation loop that walks `item_ids`, the check that rejects an
`OrderItem` whose `returned` flag is already `True` is missing.

## Expected behaviour

When the caller asks to return an item that has already been returned
(`oi.returned == True`), respond with:

```jac
{"error": "Order item " + oi_id + " is already returned", "status": 400}
```

without mutating any state, issuing a refund, or restoring stock.
The 404 (item not in order) and 400 (order not delivered) checks must
still work.

## How to verify

```bash
cd suite/agent/medium/ecommerce/jaclang/app
jac check main.jac
jac test tests/baseline.jac
```

The seeded order `W0000004` already has `oi_004.returned = True`.
Calling `return_items("W0000004", ["oi_004"], "pm_001")` must return
the 400 error above, not refund again.

# Reject cancel on non-pending orders

The `cancel_order(order_id)` endpoint cancels orders regardless of their
current status. A delivered or already-cancelled order should not be
cancellable: doing so issues a duplicate refund and corrupts the
order-state machine.

## Bug location

`app/services/orders.sv.jac`, the `cancel_order` function. The status
check is missing entirely.

## Expected behaviour

- If `order.status != "pending"`, return `{"error": "...", "status": 400}`
  without mutating the order or issuing a refund.
- If `order.status == "pending"`, cancel as today: restore stock for each
  OrderItem, issue a refund Payment for each existing payment, set
  `order.status = "cancelled"`, return the updated order.
- If the order does not exist, keep the existing 404 response.

The error message must include the current status, for example:
`"Only pending orders can be cancelled (current status: delivered)"`.

## Example

Seed order `W0000003` is delivered. After your fix:

```
cancel_order("W0000003")
=> {"error": "Only pending orders can be cancelled (current status: delivered)", "status": 400}
```

The pending order `W0000001` must still cancel successfully.

## How to verify

```bash
cd suite/agent/medium/ecommerce/jaclang/app
jac test tests/baseline.jac
```

All 16 baseline tests must pass after your fix.

# Restore stock when an order is cancelled

When `cancel_order(order_id)` cancels a pending order, it issues a
refund for every payment but does not put the reserved stock back.
Inventory permanently leaks: the order items are no longer fulfilled
but the variant stock stays decremented as if they were.

## Bug location

`app/services/orders.sv.jac`, the `cancel_order` function. Inside the
function (after the 404 + status guards), the loop that walks
`OrderItem`s and adds `oi.quantity` back to `variant.stock_qty` is
missing.

## Expected behaviour

For every `OrderItem` attached to the cancelled order:

```jac
v = find_variant(oi.variant_id);
if v is not None {
    v.stock_qty = v.stock_qty + oi.quantity;
}
```

The refund and status flip should run after the stock restore. The
404 (order not found) and 400 (non-pending status) guards must keep
working. A successful cancel still returns the updated order dict.

## How to verify

```bash
cd suite/agent/medium/ecommerce/jaclang/app
jac check main.jac
jac test tests/baseline.jac
```

## Example

A pending order with 2 of `var_001` (current stock 50): after a
successful cancel, `var_001.stock_qty` must equal 52.

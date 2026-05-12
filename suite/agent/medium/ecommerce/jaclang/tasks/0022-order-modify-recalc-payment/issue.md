# Recalculate the Payment.amount when an order's items are modified

`modify_order_items(order_id, changes)` correctly mutates the
`OrderItem` rows (changes variant, changes quantity, restores/decrements
stock as needed). But it does **not** update the order's `Payment`
record. After a modification the printed receipt amount disagrees with
the actual sum of `price_snapshot * quantity` across the items.

## Bug location

`app/services/orders.sv.jac`, the `modify_order_items` function.
After the per-change loop, the recalculation block that updates every
`Payment` whose `transaction_type == "payment"` to the new line-sum
total is missing.

## Expected behaviour

After all changes are applied:

```jac
new_total = 0.0;
for oi in [o -->][?:OrderItem] {
    new_total = new_total + (oi.price_snapshot * oi.quantity);
}
new_total_rounded = int(new_total * 100) / 100.0;
for pay in [o -->][?:Payment] {
    if pay.transaction_type == "payment" {
        pay.amount = new_total_rounded;
    }
}
```

The 404 (order not found) and 400 (status not pending) guards must keep
working. Refund payments must NOT be touched.

## How to verify

Take a pending order, modify an item's quantity, then GET the order
and verify `total == sum(payments where type == "payment")`.

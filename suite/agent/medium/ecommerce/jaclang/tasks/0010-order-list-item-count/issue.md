# Surface item-count on the orders list

The `/orders` page lists each order's id, date, shipping address, and
status, but never tells the user how many items are in the order.
Surface a per-order `item_count` from the server and render it on each
row of the orders list.

## Bug location

Two changes are required:

1. `app/services/orders.sv.jac`, the `order_dict` helper. When called
   with `include_items=False` (the path used by `list_orders`), the
   returned dict contains the shipping fields, status and timestamps
   but no `item_count`.
2. `app/pages/OrdersPage.cl.jac`. The order row renders id, date and
   address, but no item count.

## Expected behaviour

### Server (`order_dict` with `include_items=False`)

Add `"item_count": <int>` to the returned dict. The value is the
number of `OrderItem` nodes attached to the order
(`len([o -->][?:OrderItem])`).

### Client (`OrdersPage`)

Render `str(o["item_count"]) + " items"` somewhere inside the order
row (a small muted line under the address is fine).

## How to verify

```bash
cd suite/agent/medium/ecommerce/jaclang/app
jac check main.jac
jac test tests/baseline.jac
```

Backend smoke:

```bash
curl -s -X POST http://localhost:9000/function/list_orders \
    -H "Content-Type: application/json" -d '{"user_id":"user_001"}' \
    | jq '.data.result[].item_count'
# expected: 1, 1
```

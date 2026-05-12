# Fix cart total calculation

The `get_cart(user_id)` endpoint returns the correct list of items but
computes the wrong total. The current implementation sums each variant's
unit price **without multiplying by quantity**, so a cart with
3 x $29.99 items shows a total of $29.99 instead of $89.97.

## Bug location

`app/services/cart.sv.jac`, the `get_cart` function.

The faulty line is:

```jac
total = total + v.price;  # wrong: ignores quantity
```

## Expected behaviour

- `total` must equal `sum(item_price * item_quantity)` across all cart
  items in the user's cart.
- The `subtotal` field on each cart item must equal
  `price * quantity` for that item.
- If the cart is empty the total must be `0.0`.

## Example

Alice's seed cart has 1 item (var_015 at $79.99, quantity 1):

```
{
  "items": [{"id": "ci_001", "variant_id": "var_015",
             "quantity": 1, "price": 79.99, "subtotal": 79.99, ...}],
  "total": 79.99,
  "count": 1
}
```

After adding a second variant at $24.99 with quantity 3, the total
should become `79.99 + (24.99 * 3) = 154.96`, not `79.99 + 24.99 = 104.98`.

## How to verify

```bash
cd suite/agent/medium/ecommerce/jaclang/app
jac test tests/baseline.jac
```

All 16 baseline tests must pass after your fix.

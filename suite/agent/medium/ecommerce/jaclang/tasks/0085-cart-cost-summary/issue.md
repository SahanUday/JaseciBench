# Cart cost summary

`cart_cost_summary(user_id) -> dict` in cart. Returns
`{"unit_total": ..., "item_count": ...}` where `unit_total` is the
sum of `price * quantity` and `item_count` is the number of line
items.

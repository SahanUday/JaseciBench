# Customers sorted by most recent order

`customers_by_recent_order() -> list[dict]` in the orders service.
Returns user dicts (same shape as entries from `list_users`),
sorted descending by the `created_at` of each user's newest order.
Users with no orders are excluded.

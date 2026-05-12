# Filter list_orders by date range

`list_orders(user_id)` returns every order the user has ever placed.
There's no way to ask for "just orders from January 2024" or similar.
Add support for that.

Extend the endpoint so callers can pass two optional string
parameters, `from_date` and `to_date`. Each is an ISO-style timestamp
(matching the format already used in `created_at`, e.g.
`"2024-01-16T00:00:00"`).

Behaviour:
- If both are empty / not supplied, return every order (current
  behaviour preserved).
- If `from_date` is set, exclude orders whose `created_at` is strictly
  less than it.
- If `to_date` is set, exclude orders whose `created_at` is strictly
  greater than it.
- Bounds are inclusive.

The order dicts and their fields are unchanged.

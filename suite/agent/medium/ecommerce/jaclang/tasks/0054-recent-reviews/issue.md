# Recent reviews across all products

Add `recent_reviews(limit)` to the reviews service. Returns the
`limit` most recently created reviews across the entire catalog,
sorted newest-first by `created_at`.

Each entry has the same shape as the dicts returned by `list_reviews`.

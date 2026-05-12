# Endpoint: update a variant's price

Add `update_variant_price(variant_id, new_price)` to the catalog
service.

- If the variant is missing, return
  `{"error": "...", "status": 404}`.
- If `new_price` is negative, return
  `{"error": "...", "status": 400}`. Zero is fine.
- Otherwise set `v.price = new_price` and return the updated variant
  dict (same shape as the entries in `get_product`'s `variants`).

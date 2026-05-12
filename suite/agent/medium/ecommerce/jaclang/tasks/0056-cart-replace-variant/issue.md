# Replace the variant on a cart item

`cart_replace_variant(cart_item_id, new_variant_id) -> dict` in the
cart service. Updates the line's variant; returns the updated cart
item dict. 404 if the line or variant is missing.

# Deactivate a product

`deactivate_product(product_id) -> dict` in the catalog service. Sets
`active = False` on the product and returns the updated product dict
(same shape as `get_product`). 404 if missing.

Deactivated products should disappear from `list_products`.

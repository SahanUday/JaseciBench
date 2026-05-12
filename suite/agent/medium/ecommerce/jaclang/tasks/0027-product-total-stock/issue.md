# Add total stock to product dicts

When a product has multiple variants, the only way to know how many
units of the product are in stock overall is to fetch every variant
and sum manually. Expose this sum directly.

Whenever the catalog returns a product (single product fetch or
listing), include `total_stock` on the dict. It should be the sum of
`stock_qty` across all of that product's variants.

Products with no variants should report a total of 0.

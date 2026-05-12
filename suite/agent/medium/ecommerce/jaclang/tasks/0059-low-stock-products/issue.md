# Low-stock products endpoint

`low_stock_products(threshold) -> list[dict]` in the catalog service.
Returns active products that have **any** variant whose `stock_qty`
is strictly less than `threshold`. Same dict shape as `list_products`
entries.

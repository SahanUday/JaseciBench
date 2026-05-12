# List products that are entirely out of stock

We need an endpoint that returns just the products where every
variant has `stock_qty == 0`. Call it `list_out_of_stock_products()`,
returning a list of product dicts (same shape as `list_products`).

Empty catalog returns `[]`.

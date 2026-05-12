# Endpoint: top-rated products

Featured/landing pages often want a list of the catalog's best-rated
products. Add an endpoint that returns products sorted by average
review rating, highest first.

Add `top_rated_products(limit)` to the catalog service. It should
return a list of dicts, each shaped like the entries from
`list_products`, sorted by the average rating of the product's reviews
(descending). The list is truncated to `limit` entries.

A product with no reviews is treated as average rating 0.0 (it goes
at the bottom). Ties are broken however you like - the test only
inspects the relative ordering of items that actually differ in
rating.

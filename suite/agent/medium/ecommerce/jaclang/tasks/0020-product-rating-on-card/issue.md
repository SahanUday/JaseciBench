# Show product rating on the catalog card

The product card shows name, description, min price and variant count
but no review summary. Customers cannot see what other customers have
rated the product. Add `average_rating` and `review_count` to the
product dict, and render a small star rating on the card when the
product has at least one review.

## Bug location

Two changes:

1. `app/services/catalog.sv.jac`, the `product_dict` helper. No
   review-derived fields are returned.
2. `app/components/ProductCard.cl.jac`. No rating display.

## Expected behaviour

### Server (`product_dict`)

For each product, walk `[p -->][?:Review]`, compute
`review_count = len(reviews)` and
`average_rating = sum(r.rating) / review_count` (rounded to two
decimals; `0.0` if no reviews). Add both fields to the returned dict
in both branches (with and without `include_variants`).

### Client (`ProductCard`)

When `product["review_count"] > 0`, render a small line containing the
review_count and average_rating. The phrase or symbol used is up to you;
the grader looks for `average_rating` and `review_count` references in
the source.

## How to verify

```bash
curl -s -X POST http://localhost:9000/function/list_products \
    -H "Content-Type: application/json" -d '{}' \
    | jq '.data.result[] | select(.id=="prod_001") | {average_rating, review_count}'
# expected: average_rating=4.5, review_count=2
```

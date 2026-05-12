# Reject reviews with rating outside 1-5

The `add_review(product_id, user_id, rating, title, body)` endpoint
accepts any integer for `rating`, including 0, -7, 99 and 1000.
Reviews with out-of-range ratings corrupt the average computed by
`product_review_summary` and break ranking on the catalog page.

## Bug location

`app/services/reviews.sv.jac`, the `add_review` function. The rating
bounds check is missing.

## Expected behaviour

- If `rating < 1` or `rating > 5`, return
  `{"error": "Rating must be between 1 and 5", "status": 400}` without
  creating a Review.
- Otherwise create the Review as today.
- The 404 response when the product does not exist must still work.

## Example

```
add_review("prod_001", "user_001", 0, "bad", "")
=> {"error": "Rating must be between 1 and 5", "status": 400}

add_review("prod_001", "user_001", 6, "great", "")
=> {"error": "Rating must be between 1 and 5", "status": 400}

add_review("prod_001", "user_001", 5, "great", "")
=> {"id": "rev_0004", "rating": 5, ...}
```

## How to verify

```bash
cd suite/agent/medium/ecommerce/jaclang/app
jac test tests/baseline.jac
```

All 16 baseline tests must pass after your fix.

# Endpoint: list every review a user has written

The reviews service can list reviews for a single product, but there's
no way to fetch all reviews a particular user has written across the
catalog. Add an endpoint for this.

It needs to return every Review whose `user_id` matches the given
user, regardless of which product the review is on. Each entry in
the result should look like the dicts already returned by
`list_reviews` (id, product_id, user_id, rating, title, body,
created_at). The result should also tell the caller how many reviews
were found.

A user with no reviews should get an empty result, not an error.

# Endpoint: users with at least N orders

Add `users_with_min_orders(min_count)` to the orders service. Return a
list of user dicts (same shape as entries from `list_users`) for users
whose total number of Orders is greater than or equal to `min_count`.

A user with no orders has 0. `min_count = 0` returns every user.

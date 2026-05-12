# Cart total quantity endpoint

Add `cart_total_quantity(user_id)` returning a single int: the sum of
all `quantity` fields across the user's CartItems.

User with no cart items returns 0.

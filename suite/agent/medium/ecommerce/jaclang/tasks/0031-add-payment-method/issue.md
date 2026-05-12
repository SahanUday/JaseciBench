# Endpoint: add a payment method to a user

Users currently come with one seeded payment method each, but there
is no way to add another. Add `add_payment_method(user_id, card_brand,
last_four)` to the users service.

It should:

- Find the user by `user_id`, return `{"error": "...", "status": 404}`
  if missing.
- Create a new `PaymentMethod` node attached to that user, with a
  fresh `id` (e.g. `"pm_<n>"`), the given `card_brand` and `last_four`,
  and `is_default = False` (the existing default stays default).
- Return the new payment method dict (same shape as entries from
  `list_payment_methods`).

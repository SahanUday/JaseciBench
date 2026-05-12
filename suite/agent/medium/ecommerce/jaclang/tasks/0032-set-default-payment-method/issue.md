# Endpoint: set a user's default payment method

Add `set_default_payment_method(user_id, payment_method_id)` to the
users service. It should:

- Walk the user's PaymentMethods.
- Mark the one whose `id == payment_method_id` as `is_default = True`,
  and set every other one belonging to the user to
  `is_default = False`.
- Return the updated payment method dict (same shape as entries from
  `list_payment_methods`) on success.
- Return `{"error": "...", "status": 404}` if neither the user nor the
  payment method exists, or the payment method doesn't belong to that
  user.

Exactly one payment method per user should end up with `is_default ==
True`.

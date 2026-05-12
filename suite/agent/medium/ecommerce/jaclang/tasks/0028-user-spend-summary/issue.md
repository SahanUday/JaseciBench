# Endpoint: user spend summary

Customer service often needs a single number for "how much has this
user actually paid us" - i.e. payments minus refunds. There's no
endpoint for it right now; you have to walk every order and every
payment.

Add an endpoint `get_user_spend(user_id)` to the orders service that
returns three fields:

- `total_paid`: sum of every `payment` transaction across that user's
  orders
- `total_refunded`: sum of every `refund` transaction across that
  user's orders
- `net_spent`: `total_paid - total_refunded`

A user with no orders should still get a valid result (all three are
0.0). Round nothing manually - the raw floats are fine.

# Total revenue endpoint

`total_revenue() -> float` in the orders service. Returns the sum of
every Payment whose `transaction_type == "payment"`, minus every
`"refund"` Payment, across all orders.

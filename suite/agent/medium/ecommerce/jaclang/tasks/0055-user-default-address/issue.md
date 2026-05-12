# Get a user's default address

Add `get_default_address(user_id)` to the users service. Returns the
address dict (same shape as entries from `list_addresses`) where
`is_default` is True.

If the user has no addresses, or none marked default, return None.

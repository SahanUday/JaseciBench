# Endpoint: update a user's username

Add `update_username(user_id, new_username)` to the users service.

- Find the user by `user_id`; if missing, return
  `{"error": "...", "status": 404}`.
- If `new_username` is already taken by a different user, return
  `{"error": "...", "status": 400}`. The check is case-sensitive.
- Otherwise set `u.username = new_username` and return the updated
  user dict (same shape as entries from `list_users`).
- Setting a user's username to its current value is a no-op success
  (returns the same user dict, no error).

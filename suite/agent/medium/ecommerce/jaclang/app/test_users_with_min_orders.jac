"""Test users_with_min_orders endpoint."""

import from services.orders { users_with_min_orders }


with entry {
    # Test with min_count = 0 (should return all users)
    result_0 = users_with_min_orders(0);
    print("Users with >= 0 orders:", result_0);
    
    # Test with min_count = 1 (should return users with at least 1 order)
    result_1 = users_with_min_orders(1);
    print("Users with >= 1 orders:", result_1);
    
    # Test with min_count = 2 (should return users with at least 2 orders)
    result_2 = users_with_min_orders(2);
    print("Users with >= 2 orders:", result_2);
    
    # Test with min_count = 10 (should return users with at least 10 orders)
    result_10 = users_with_min_orders(10);
    print("Users with >= 10 orders:", result_10);
    
    # Verify the structure of returned user dicts
    if len(result_0) > 0 {
        first_user = result_0[0];
        print("Sample user dict keys:", list(first_user.keys()));
        print("Sample user dict:", first_user);
    }
}

"""Test users_with_min_orders function."""

import from services.orders { users_with_min_orders }

with entry {
    print("Testing users_with_min_orders...");
    
    # Test 1: min_count = 0 should return all users
    all_users = users_with_min_orders(0);
    print(f"\nTest 1 - min_count=0: Found {len(all_users)} users");
    for u in all_users {
        print(f"  - {u['username']} ({u['id']})");
    }
    
    # Test 2: min_count = 1 should return users with at least 1 order
    users_1plus = users_with_min_orders(1);
    print(f"\nTest 2 - min_count=1: Found {len(users_1plus)} users with 1+ orders");
    for u in users_1plus {
        print(f"  - {u['username']} ({u['id']})");
    }
    
    # Test 3: min_count = 2 should return users with at least 2 orders
    users_2plus = users_with_min_orders(2);
    print(f"\nTest 3 - min_count=2: Found {len(users_2plus)} users with 2+ orders");
    for u in users_2plus {
        print(f"  - {u['username']} ({u['id']})");
    }
    
    # Test 4: Very high min_count should return empty list
    users_high = users_with_min_orders(100);
    print(f"\nTest 4 - min_count=100: Found {len(users_high)} users with 100+ orders");
    
    print("\nAll tests completed!");
}

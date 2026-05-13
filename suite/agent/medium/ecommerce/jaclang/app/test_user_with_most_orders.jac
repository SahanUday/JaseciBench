"""Test for user_with_most_orders function"""

import from services.orders { user_with_most_orders, list_orders }


test "user_with_most_orders returns a user with max orders" {
    result = user_with_most_orders();
    assert result != "";
    
    # Verify the result is one of the users with 2 orders (user_001 or user_002)
    user_001_orders = list_orders("user_001");
    user_002_orders = list_orders("user_002");
    user_003_orders = list_orders("user_003");
    
    # user_001 and user_002 should both have 2 orders
    assert len(user_001_orders) == 2;
    assert len(user_002_orders) == 2;
    assert len(user_003_orders) == 1;
    
    # Result should be one of the users with most orders
    assert result in ["user_001", "user_002"];
}

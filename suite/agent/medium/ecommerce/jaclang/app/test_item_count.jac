"""Quick test to verify item_count is in order_dict response."""

import from models { Order, OrderItem }
import from services.orders { order_dict }


with entry {
    # Create a test order
    test_order = Order(
        id="test_order_001",
        user_id="user_001",
        status="pending",
        shipping_address1="123 Main St",
        shipping_city="Springfield",
        shipping_state="IL",
        shipping_zip="62701"
    );
    
    # Attach some items to it
    test_order ++> OrderItem(
        id="item_001",
        quantity=2,
        price_snapshot=50.0
    );
    
    test_order ++> OrderItem(
        id="item_002",
        quantity=1,
        price_snapshot=75.0
    );
    
    # Get the dict with include_items=False (like list_orders uses)
    order_summary = order_dict(test_order, include_items=False);
    
    # Verify item_count is present
    if "item_count" in order_summary {
        print("✓ item_count is present in dict");
        print("  item_count value:", order_summary["item_count"]);
        if order_summary["item_count"] == 2 {
            print("✓ item_count is correct (2 items)");
        } else {
            print("✗ item_count is wrong, expected 2, got:", order_summary["item_count"]);
        }
    } else {
        print("✗ item_count is missing from dict!");
        print("  dict keys:", list(order_summary.keys()));
    }
}

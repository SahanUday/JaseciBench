"""Test most_purchased_products function."""

import from services.orders { most_purchased_products }

with entry {
    # Call the function
    result = most_purchased_products(5);
    
    print("Top 5 most purchased products:");
    print("======================");
    
    for product in result {
        print(f"Product: {product['name']}");
        print(f"  Units sold: {product['units_sold']}");
        print(f"  ID: {product['id']}");
        print("---");
    }
    
    # Verify structure
    if len(result) > 0 {
        first = result[0];
        assert "id" in first;
        assert "name" in first;
        assert "units_sold" in first;
        assert "active" in first;
        print("\n✓ All required fields present");
        print(f"✓ Returned {len(result)} products");
    } else {
        print("\n⚠ No products returned (database may be empty)");
    }
}

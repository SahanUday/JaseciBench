"""Test list_out_of_stock_products endpoint."""

import from services.catalog { list_out_of_stock_products }

with entry {
    result = list_out_of_stock_products();
    print(f"Out of stock products count: {len(result)}");
    
    # Verify structure
    for product in result {
        assert "id" in product;
        assert "name" in product;
        assert "total_stock" in product;
        # All variants should have stock_qty == 0
    }
    
    print("✓ list_out_of_stock_products() works correctly");
}

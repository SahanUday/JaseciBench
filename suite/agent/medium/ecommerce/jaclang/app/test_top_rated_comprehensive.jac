"""Comprehensive test for top_rated_products endpoint."""

import from services.catalog { top_rated_products }

with entry {
    print("=== Testing top_rated_products endpoint ===\n");
    
    # Test 1: Limit of 3
    print("Test 1: Limit of 3");
    result_3 = top_rated_products(3);
    assert len(result_3) <= 3;
    print(f"✓ Got {len(result_3)} products (limit: 3)");
    
    # Test 2: Limit of 10 (more than available)
    print("\nTest 2: Limit of 10 (may exceed available)");
    result_10 = top_rated_products(10);
    print(f"✓ Got {len(result_10)} products (limit: 10)");
    
    # Test 3: Limit of 1 (single product)
    print("\nTest 3: Limit of 1");
    result_1 = top_rated_products(1);
    assert len(result_1) <= 1;
    if len(result_1) > 0 {
        top_product = result_1[0];
        print(f"✓ Top-rated product: {top_product['name']} ({top_product['average_rating']} rating)");
    }
    
    # Test 4: Verify sorting across all results
    print("\nTest 4: Verify descending sort order");
    all_products = top_rated_products(100);
    is_sorted = True;
    for i in range(len(all_products) - 1) {
        if all_products[i]["average_rating"] < all_products[i+1]["average_rating"] {
            is_sorted = False;
            break;
        }
    }
    assert is_sorted;
    print(f"✓ All {len(all_products)} products are sorted by rating (descending)");
    
    # Test 5: Verify structure of returned dicts
    print("\nTest 5: Verify dict structure");
    required_fields = ["id", "name", "description", "category_id", "active", "variants", "min_price", "average_rating", "review_count", "total_stock"];
    for product in result_3 {
        for field in required_fields {
            assert field in product;
        }
    }
    print(f"✓ All returned products have required fields");
    
    print("\n=== All tests passed! ===");
}

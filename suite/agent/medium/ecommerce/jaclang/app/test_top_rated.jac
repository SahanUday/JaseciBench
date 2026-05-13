"""Test for top_rated_products endpoint."""

import from services.catalog { top_rated_products }

with entry {
    # Test with limit of 5
    result = top_rated_products(5);
    print(f"Top 5 rated products count: {len(result)}");
    
    # Verify structure
    for product in result {
        assert "id" in product;
        assert "name" in product;
        assert "average_rating" in product;
        assert "review_count" in product;
    }
    
    print("✓ All products have required fields");
    
    # Verify ordering (descending by average_rating)
    for i in range(len(result) - 1) {
        assert result[i]["average_rating"] >= result[i+1]["average_rating"];
    }
    
    print("✓ Products are sorted by average_rating (descending)");
    
    # Verify limit is respected
    assert len(result) <= 5;
    print(f"✓ Result count ({len(result)}) respects limit (5)");
    
    # Print sample results
    print("\nSample top-rated products:");
    for product in result {
        print(f"  - {product['name']}: {product['average_rating']} avg rating ({product['review_count']} reviews)");
    }
}

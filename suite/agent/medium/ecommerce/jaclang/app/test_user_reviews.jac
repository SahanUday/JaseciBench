"""Test the list_user_reviews endpoint."""

import from services.reviews { list_user_reviews }
import from seed { seed_catalog }


with entry {
    # Seed the catalog first
    seed_catalog();
    
    # Test 1: User with reviews
    print("\n== Test 1: User with reviews (user_001) ==");
    result1 = list_user_reviews("user_001");
    print(f"Count: {result1['count']}");
    print(f"Reviews: {result1['reviews']}");
    
    # Test 2: Another user with reviews
    print("\n== Test 2: Another user with reviews (user_002) ==");
    result2 = list_user_reviews("user_002");
    print(f"Count: {result2['count']}");
    print(f"Reviews: {result2['reviews']}");
    
    # Test 3: User with no reviews
    print("\n== Test 3: User with no reviews (user_999) ==");
    result3 = list_user_reviews("user_999");
    print(f"Count: {result3['count']}");
    print(f"Reviews: {result3['reviews']}");
    
    # Verify results
    print("\n== Verification ==");
    if result1['count'] == 1 {
        print("✓ user_001 has 1 review");
    } else {
        print(f"✗ user_001 should have 1 review, got {result1['count']}");
    }
    
    if result2['count'] == 1 {
        print("✓ user_002 has 1 review");
    } else {
        print(f"✗ user_002 should have 1 review, got {result2['count']}");
    }
    
    if result3['count'] == 0 {
        print("✓ user_999 has no reviews (empty result)");
    } else {
        print(f"✗ user_999 should have 0 reviews, got {result3['count']}");
    }
    
    # Check structure of returned reviews
    if result1['count'] > 0 {
        review = result1['reviews'][0];
        required_fields = ["id", "product_id", "user_id", "rating", "title", "body", "created_at"];
        all_present = True;
        for field in required_fields {
            if field not in review {
                print(f"✗ Missing field: {field}");
                all_present = False;
            }
        }
        if all_present {
            print("✓ All required fields present in review");
        }
    }
    
    print("\n== Tests Complete ==");
}

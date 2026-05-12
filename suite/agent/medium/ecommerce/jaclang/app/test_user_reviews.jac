"""Test script for list_user_reviews endpoint."""

import from services.reviews { list_user_reviews }
import from seed { seed_catalog }


with entry {
    # Seed the database
    seed_catalog();
    
    print("Testing list_user_reviews endpoint...\n");
    
    # Test 1: User with one review
    print("Test 1: User user_001 (should have 1 review)");
    result1 = list_user_reviews("user_001");
    print(f"  Count: {result1['count']}");
    print(f"  Reviews: {result1['reviews']}\n");
    
    # Test 2: Another user with one review
    print("Test 2: User user_002 (should have 1 review)");
    result2 = list_user_reviews("user_002");
    print(f"  Count: {result2['count']}");
    print(f"  Reviews: {result2['reviews']}\n");
    
    # Test 3: User with no reviews
    print("Test 3: User user_999 (should have 0 reviews)");
    result3 = list_user_reviews("user_999");
    print(f"  Count: {result3['count']}");
    print(f"  Reviews: {result3['reviews']}\n");
    
    # Verify the structure of returned reviews
    if result1['count'] > 0 {
        review = result1['reviews'][0];
        print("Review structure check:");
        print(f"  Has 'id': {'id' in review}");
        print(f"  Has 'product_id': {'product_id' in review}");
        print(f"  Has 'user_id': {'user_id' in review}");
        print(f"  Has 'rating': {'rating' in review}");
        print(f"  Has 'title': {'title' in review}");
        print(f"  Has 'body': {'body' in review}");
        print(f"  Has 'created_at': {'created_at' in review}");
    }
    
    print("\nAll tests completed!");
}

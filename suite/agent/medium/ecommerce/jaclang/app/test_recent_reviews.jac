"""Test recent_reviews endpoint."""

import from services.reviews { recent_reviews }


with entry {
    # Test with limit of 5
    result = recent_reviews(5);
    print("Recent reviews (limit=5):");
    print(f"Count: {result['count']}");
    
    # Test with limit of 10
    result = recent_reviews(10);
    print("\nRecent reviews (limit=10):");
    print(f"Count: {result['count']}");
    
    # Verify sorting is newest-first
    if len(result["reviews"]) > 1 {
        is_sorted = True;
        for i in range(len(result["reviews"]) - 1) {
            curr = result["reviews"][i]["created_at"];
            next_val = result["reviews"][i + 1]["created_at"];
            if curr < next_val {
                print(f"ERROR: Not sorted correctly! {curr} < {next_val}");
                is_sorted = False;
            }
        }
        if is_sorted {
            print("✓ Reviews are correctly sorted newest-first");
        }
    }
}

"""Verification script for multi-criteria search functionality."""

import from services.catalog { search_products, list_categories }


with entry {
    print("\n== Multi-Criteria Search Verification ==\n");

    # Test 1: Category filter only (Tech category, min price $80)
    print("Test 1: Category filter (cat_004) + min_price (80.0)");
    results = search_products("", "cat_004", 80.0, 0.0);
    names = [p["name"] for p in results];
    print(f"  Results: {names}");
    print(f"  Expected: ['Keyboard', 'Headphones']");
    print(f"  ✓ PASS" if set(names) == {"Keyboard", "Headphones"} else f"  ✗ FAIL");

    # Test 2: Text search only
    print("\nTest 2: Text search (q='shirt')");
    results = search_products("shirt", "", 0.0, 0.0);
    names = [p["name"] for p in results];
    print(f"  Results: {names}");
    print(f"  Expected: ['T-Shirt']");
    print(f"  ✓ PASS" if names == ["T-Shirt"] else f"  ✗ FAIL");

    # Test 3: Max price filter
    print("\nTest 3: Max price filter (max_price=30.0)");
    results = search_products("", "", 0.0, 30.0);
    names = [p["name"] for p in results];
    print(f"  Results: {names}");
    print(f"  Found {len(names)} products with max price <= $30");
    print(f"  ✓ PASS" if len(names) >= 2 else f"  ✗ FAIL");

    # Test 4: All filters empty returns all products
    print("\nTest 4: All filters empty (should return all active products)");
    results = search_products("", "", 0.0, 0.0);
    print(f"  Results: {len(results)} products");
    print(f"  ✓ PASS" if len(results) >= 5 else f"  ✗ FAIL");

    # Test 5: Category dropdown data
    print("\nTest 5: Category list for dropdown");
    categories = list_categories();
    cat_names = [c["name"] for c in categories];
    print(f"  Categories: {cat_names}");
    print(f"  ✓ PASS" if len(categories) >= 5 else f"  ✗ FAIL");

    # Test 6: Combined filters (text + category)
    print("\nTest 6: Combined filters (q='keyboard' + category='cat_004')");
    results = search_products("keyboard", "cat_004", 0.0, 0.0);
    names = [p["name"] for p in results];
    print(f"  Results: {names}");
    print(f"  Expected: ['Keyboard']");
    print(f"  ✓ PASS" if names == ["Keyboard"] else f"  ✗ FAIL");

    print("\n== Verification Complete ==\n");
}

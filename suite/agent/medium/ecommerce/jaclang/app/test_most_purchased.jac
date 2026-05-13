"""Test script for most_purchased_products function."""

import from services.orders { most_purchased_products }

with entry {
    print("Testing most_purchased_products...");
    
    # Get top 5 most purchased products
    results = most_purchased_products(5);
    
    print(f"\nTop {len(results)} most purchased products:");
    for (i, product) in enumerate(results) {
        print(f"{i + 1}. {product['name']} - {product['total_units_sold']} units sold");
    }
    
    # Get all products (no limit)
    all_results = most_purchased_products(0);
    print(f"\n\nTotal products with sales: {len(all_results)}");
}

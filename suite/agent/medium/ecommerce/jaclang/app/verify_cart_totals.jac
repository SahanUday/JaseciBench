"""Verify cart shipping and grand total calculation."""

import from services.cart { get_cart }
import from services.catalog { ensure_seeded }

with entry {
    ensure_seeded();
    
    cart = get_cart("user_001");
    
    print("Cart Summary:");
    print("-------------");
    print(f"Items: {cart['count']}");
    print(f"Subtotal: ${cart['total']}");
    print(f"Shipping: ${cart['shipping']}");
    print(f"Grand Total: ${cart['grand_total']}");
    print();
    
    # Verify calculations
    expected_shipping = 5.99 if cart['total'] > 0.0 else 0.0;
    expected_grand = round(cart['total'] + expected_shipping, 2);
    
    assert cart['shipping'] == expected_shipping, f"Shipping mismatch: expected {expected_shipping}, got {cart['shipping']}";
    assert cart['grand_total'] == expected_grand, f"Grand total mismatch: expected {expected_grand}, got {cart['grand_total']}";
    
    print("✓ All calculations correct!");
    print(f"✓ Shipping: {cart['shipping']} (expected: {expected_shipping})");
    print(f"✓ Grand Total: {cart['grand_total']} (expected: {expected_grand})");
}

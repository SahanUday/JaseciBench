"""Test set_default_payment_method endpoint."""

import from models { UserProfile, PaymentMethod }
import from services.users { set_default_payment_method, list_payment_methods }
import from services.catalog { ensure_seeded }


with entry {
    ensure_seeded();
    
    # Get first user (from seeded data)
    users = [root() -->][?:UserProfile];
    if len(users) == 0 {
        print("ERROR: No users found");
    } else {
        user = users[0];
        user_id = user.id;
        print(f"Testing with user: {user_id}");
        
        # List payment methods before
        pms_before = list_payment_methods(user_id);
        print(f"Payment methods before: {len(pms_before)}");
        for pm in pms_before {
            print(f"  - {pm['id']}: is_default={pm['is_default']}");
        }
        
        # Try to set default on first payment method
        if len(pms_before) > 0 {
            first_pm_id = pms_before[0]["id"];
            result = set_default_payment_method(user_id, first_pm_id);
            print(f"\nSet {first_pm_id} as default: {result}");
            
            # List payment methods after
            pms_after = list_payment_methods(user_id);
            print(f"\nPayment methods after:");
            for pm in pms_after {
                print(f"  - {pm['id']}: is_default={pm['is_default']}");
            }
            
            # Verify exactly one is default
            default_count = len([pm for pm in pms_after if pm["is_default"]]);
            print(f"\nDefault count: {default_count} (should be 1)");
            
            # Test error cases
            print("\n--- Testing error cases ---");
            
            # Non-existent user
            err1 = set_default_payment_method("nonexistent_user", "pm_001");
            print(f"Non-existent user: {err1}");
            
            # Non-existent payment method
            err2 = set_default_payment_method(user_id, "nonexistent_pm");
            print(f"Non-existent payment method: {err2}");
        } else {
            print("ERROR: User has no payment methods");
        }
    }
}

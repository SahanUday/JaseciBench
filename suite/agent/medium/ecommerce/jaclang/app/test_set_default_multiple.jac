"""Test set_default_payment_method with multiple payment methods."""

import from models { UserProfile, PaymentMethod }
import from services.users { set_default_payment_method, list_payment_methods, add_payment_method }
import from services.catalog { ensure_seeded }


with entry {
    ensure_seeded();
    
    # Get first user
    users = [root() -->][?:UserProfile];
    if len(users) == 0 {
        print("ERROR: No users found");
    } else {
        user = users[0];
        user_id = user.id;
        print(f"Testing with user: {user_id}");
        
        # Add extra payment methods
        print("\nAdding extra payment methods...");
        add_payment_method(user_id, "Mastercard", "5555");
        add_payment_method(user_id, "Amex", "3782");
        
        # List payment methods
        pms = list_payment_methods(user_id);
        print(f"Total payment methods: {len(pms)}");
        for pm in pms {
            print(f"  - {pm['id']}: {pm['card_brand']} is_default={pm['is_default']}");
        }
        
        # Set second payment method as default
        if len(pms) >= 2 {
            second_pm_id = pms[1]["id"];
            print(f"\nSetting {second_pm_id} as default...");
            result = set_default_payment_method(user_id, second_pm_id);
            print(f"Result: {result}");
            
            # Verify exactly one is default and it's the right one
            pms_after = list_payment_methods(user_id);
            print(f"\nPayment methods after:");
            default_count = 0;
            default_id = None;
            for pm in pms_after {
                is_def = pm["is_default"];
                print(f"  - {pm['id']}: {pm['card_brand']} is_default={is_def}");
                if is_def {
                    default_count += 1;
                    default_id = pm["id"];
                }
            }
            
            print(f"\nValidation:");
            print(f"  - Exactly 1 default: {default_count == 1}");
            print(f"  - Correct default: {default_id == second_pm_id}");
        }
    }
}

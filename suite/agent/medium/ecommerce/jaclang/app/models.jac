"""E-commerce nodes and edges."""

node Category {
    has id: str;
    has name: str;
    has description: str = "";
}

node Product {
    has id: str;
    has name: str;
    has description: str = "";
    has category_id: str = "";
    has active: bool = True;
}

node Variant {
    has id: str;
    has price: float;
    has color: str = "";
    has size: str = "";
    has material: str = "";
    has stock_qty: int = 0;
}

node Review {
    has id: str;
    has rating: int;
    has product_id: str = "";
    has title: str = "";
    has body: str = "";
    has user_id: str = "";
    has created_at: str = "";
}

node CartItem {
    has id: str;
    has user_id: str;
    has variant_id: str;
    has quantity: int = 1;
}

node Order {
    has id: str;
    has user_id: str;
    has status: str = "pending";
    has shipping_address1: str = "";
    has shipping_address2: str = "";
    has shipping_city: str = "";
    has shipping_state: str = "";
    has shipping_zip: str = "";
    has shipping_country: str = "USA";
    has created_at: str = "";
}

node OrderItem {
    has id: str;
    has quantity: int;
    has price_snapshot: float;
    has variant_id: str = "";
    has returned: bool = False;
}

node Payment {
    has id: str;
    has amount: float;
    has transaction_type: str = "payment";
    has payment_method_id: str = "";
    has created_at: str = "";
}

node Address {
    has id: str;
    has address1: str;
    has city: str;
    has state: str;
    has zip_code: str;
    has user_id: str = "";
    has address2: str = "";
    has country: str = "USA";
    has is_default: bool = False;
}

node PaymentMethod {
    has id: str;
    has card_brand: str = "";
    has last_four: str = "";
    has user_id: str = "";
    has is_default: bool = False;
}

node UserProfile {
    has id: str;
    has username: str;
    has email: str;
    has first_name: str = "";
    has last_name: str = "";
}

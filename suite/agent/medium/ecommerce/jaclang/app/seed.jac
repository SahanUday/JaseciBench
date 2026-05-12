"""Idempotent seed: populates graph with reference data on first call."""

import from models {
    Category, Product, Variant, Review,
    CartItem, Order, OrderItem, Payment,
    Address, PaymentMethod, UserProfile
}

def:pub seed_catalog() -> None {
    if [root() -->][?:Category] { return; }

    cat_clothing = Category(id="cat_001", name="Clothing",   description="Apparel and accessories");
    cat_kitchen  = Category(id="cat_002", name="Kitchen",    description="Kitchen appliances");
    cat_office   = Category(id="cat_003", name="Office",     description="Office furniture and equipment");
    cat_tech     = Category(id="cat_004", name="Technology", description="Tech gadgets and electronics");
    cat_home     = Category(id="cat_005", name="Home",       description="Smart home devices");
    cat_fitness  = Category(id="cat_006", name="Fitness",    description="Sports and fitness gear");
    root() ++> cat_clothing;
    root() ++> cat_kitchen;
    root() ++> cat_office;
    root() ++> cat_tech;
    root() ++> cat_home;
    root() ++> cat_fitness;

    p_tshirt = Product(id="prod_001", name="T-Shirt",
        description="Comfortable cotton t-shirt available in multiple colors",
        category_id="cat_001");
    root() ++> p_tshirt;
    p_tshirt ++> Variant(id="var_001", price=19.99, color="Red",   size="S", material="Cotton", stock_qty=50);
    p_tshirt ++> Variant(id="var_002", price=19.99, color="Blue",  size="M", material="Cotton", stock_qty=30);
    p_tshirt ++> Variant(id="var_003", price=19.99, color="Green", size="L", material="Cotton", stock_qty=20);

    p_bottle = Product(id="prod_002", name="Water Bottle",
        description="Insulated stainless steel water bottle, keeps drinks cold for 24 hours",
        category_id="cat_006");
    root() ++> p_bottle;
    p_bottle ++> Variant(id="var_004", price=24.99, color="Silver", size="500ml", material="Stainless Steel", stock_qty=75);
    p_bottle ++> Variant(id="var_005", price=29.99, color="Black",  size="750ml", material="Stainless Steel", stock_qty=60);

    p_chair = Product(id="prod_003", name="Office Chair",
        description="Ergonomic office chair with lumbar support and adjustable height",
        category_id="cat_003");
    root() ++> p_chair;
    p_chair ++> Variant(id="var_006", price=299.99, color="Black", size="Standard", material="Mesh", stock_qty=15);
    p_chair ++> Variant(id="var_007", price=299.99, color="Gray",  size="Standard", material="Mesh", stock_qty=10);

    p_keyboard = Product(id="prod_004", name="Keyboard",
        description="Mechanical keyboard with RGB backlight and tactile switches",
        category_id="cat_004");
    root() ++> p_keyboard;
    p_keyboard ++> Variant(id="var_008", price=89.99,  color="White", size="TKL",       material="Plastic", stock_qty=40);
    p_keyboard ++> Variant(id="var_009", price=99.99,  color="Black", size="Full Size", material="Plastic", stock_qty=35);

    p_headphones = Product(id="prod_005", name="Headphones",
        description="Over-ear wireless headphones with active noise cancellation",
        category_id="cat_004");
    root() ++> p_headphones;
    p_headphones ++> Variant(id="var_010", price=149.99, color="Black",  size="One Size", material="Plastic/Leather", stock_qty=25);
    p_headphones ++> Variant(id="var_011", price=149.99, color="Silver", size="One Size", material="Plastic/Leather", stock_qty=20);

    p_shoes = Product(id="prod_006", name="Running Shoes",
        description="Lightweight running shoes with responsive cushioning",
        category_id="cat_006");
    root() ++> p_shoes;
    p_shoes ++> Variant(id="var_012", price=79.99, color="Blue",  size="9",  material="Mesh/Rubber", stock_qty=30);
    p_shoes ++> Variant(id="var_013", price=79.99, color="Red",   size="10", material="Mesh/Rubber", stock_qty=25);
    p_shoes ++> Variant(id="var_014", price=79.99, color="Black", size="11", material="Mesh/Rubber", stock_qty=20);

    p_coffee = Product(id="prod_007", name="Coffee Maker",
        description="Programmable drip coffee maker with 12-cup capacity and built-in grinder",
        category_id="cat_002");
    root() ++> p_coffee;
    var_015 = Variant(id="var_015", price=79.99, color="Black",  size="12-Cup", material="Plastic/Metal", stock_qty=20);
    p_coffee ++> var_015;
    p_coffee ++> Variant(id="var_016", price=84.99, color="Silver", size="12-Cup", material="Plastic/Metal", stock_qty=15);

    p_thermo = Product(id="prod_008", name="Smart Thermostat",
        description="WiFi-enabled smart thermostat with energy-saving scheduling",
        category_id="cat_005");
    root() ++> p_thermo;
    p_thermo ++> Variant(id="var_017", price=129.99, color="White", size="Standard", material="Plastic", stock_qty=30);
    p_thermo ++> Variant(id="var_018", price=129.99, color="Black", size="Standard", material="Plastic", stock_qty=25);

    u_alice = UserProfile(id="user_001", username="alice", email="alice@example.com",
        first_name="Alice", last_name="Johnson");
    root() ++> u_alice;
    u_alice ++> Address(id="addr_001", user_id="user_001", address1="123 Main St", city="New York",
        state="NY", zip_code="10001", country="USA", is_default=True);
    u_alice ++> PaymentMethod(id="pm_001", user_id="user_001", card_brand="Visa", last_four="4242", is_default=True);

    u_bob = UserProfile(id="user_002", username="bob", email="bob@example.com",
        first_name="Bob", last_name="Smith");
    root() ++> u_bob;
    u_bob ++> Address(id="addr_002", user_id="user_002", address1="456 Oak Ave", city="Los Angeles",
        state="CA", zip_code="90001", country="USA", is_default=True);
    u_bob ++> PaymentMethod(id="pm_002", user_id="user_002", card_brand="Mastercard", last_four="5555", is_default=True);

    u_carol = UserProfile(id="user_003", username="carol", email="carol@example.com",
        first_name="Carol", last_name="Williams");
    root() ++> u_carol;
    u_carol ++> Address(id="addr_003", user_id="user_003", address1="789 Pine Rd", city="Chicago",
        state="IL", zip_code="60601", country="USA", is_default=True);
    u_carol ++> PaymentMethod(id="pm_003", user_id="user_003", card_brand="Visa", last_four="1234", is_default=True);

    o1 = Order(id="W0000001", user_id="user_001", status="pending",
        shipping_address1="123 Main St", shipping_city="New York",
        shipping_state="NY", shipping_zip="10001", shipping_country="USA",
        created_at="2024-01-15T10:00:00");
    root() ++> o1;
    o1 ++> OrderItem(id="oi_001", quantity=2, price_snapshot=19.99, variant_id="var_001");
    o1 ++> Payment(id="pay_001", amount=39.98, transaction_type="payment",
        payment_method_id="pm_001", created_at="2024-01-15T10:00:00");

    o2 = Order(id="W0000002", user_id="user_002", status="processed",
        shipping_address1="456 Oak Ave", shipping_city="Los Angeles",
        shipping_state="CA", shipping_zip="90001", shipping_country="USA",
        created_at="2024-01-16T11:00:00");
    root() ++> o2;
    o2 ++> OrderItem(id="oi_002", quantity=1, price_snapshot=149.99, variant_id="var_010");
    o2 ++> Payment(id="pay_002", amount=149.99, transaction_type="payment",
        payment_method_id="pm_002", created_at="2024-01-16T11:00:00");

    p_tshirt ++> Review(id="rev_001", product_id="prod_001", rating=5,
        title="Great fit", body="Comfortable cotton, true to size",
        user_id="user_001", created_at="2024-02-01T10:00:00");
    p_tshirt ++> Review(id="rev_002", product_id="prod_001", rating=4,
        title="Nice color", body="Color is vibrant, fits as expected",
        user_id="user_002", created_at="2024-02-05T11:00:00");
    p_headphones ++> Review(id="rev_003", product_id="prod_005", rating=5,
        title="Amazing sound", body="Noise cancellation is exceptional",
        user_id="user_003", created_at="2024-02-10T12:00:00");

    o3 = Order(id="W0000003", user_id="user_003", status="delivered",
        shipping_address1="789 Pine Rd", shipping_city="Chicago",
        shipping_state="IL", shipping_zip="60601", shipping_country="USA",
        created_at="2024-01-17T12:00:00");
    root() ++> o3;
    o3 ++> OrderItem(id="oi_003", quantity=1, price_snapshot=299.99, variant_id="var_006");
    o3 ++> Payment(id="pay_003", amount=299.99, transaction_type="payment",
        payment_method_id="pm_003", created_at="2024-01-17T12:00:00");

    o4 = Order(id="W0000004", user_id="user_001", status="returned",
        shipping_address1="123 Main St", shipping_city="New York",
        shipping_state="NY", shipping_zip="10001", shipping_country="USA",
        created_at="2024-01-18T13:00:00");
    root() ++> o4;
    o4 ++> OrderItem(id="oi_004", quantity=1, price_snapshot=89.99, variant_id="var_008", returned=True);
    o4 ++> Payment(id="pay_004", amount=89.99, transaction_type="payment",
        payment_method_id="pm_001", created_at="2024-01-18T13:00:00");
    o4 ++> Payment(id="pay_005", amount=89.99, transaction_type="refund",
        payment_method_id="pm_001", created_at="2024-01-19T09:00:00");

    o5 = Order(id="W0000005", user_id="user_002", status="cancelled",
        shipping_address1="456 Oak Ave", shipping_city="Los Angeles",
        shipping_state="CA", shipping_zip="90001", shipping_country="USA",
        created_at="2024-01-19T14:00:00");
    root() ++> o5;
    o5 ++> OrderItem(id="oi_005", quantity=2, price_snapshot=24.99, variant_id="var_004");
    o5 ++> Payment(id="pay_006", amount=49.98, transaction_type="refund",
        payment_method_id="pm_002", created_at="2024-01-19T14:30:00");

    ci = CartItem(id="ci_001", user_id="user_001", variant_id="var_015", quantity=1);
    root() ++> ci;
}

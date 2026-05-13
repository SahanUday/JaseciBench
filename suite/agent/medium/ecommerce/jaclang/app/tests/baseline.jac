"""Baseline regression tests for the e-commerce app.

These tests pass on the unmodified base app and serve as a sanity check
that the candidate codebase compiles and the seed loaded correctly.
Hidden grading tests live alongside each task in the vault.
"""

import from services.catalog { list_categories, list_products, get_product, search_products, deactivate_product }
import from services.users { get_profile, list_addresses, list_payment_methods }
import from services.cart { get_cart }
import from services.orders { list_orders, get_order }
import from services.reviews { list_reviews, list_user_reviews }


# Catalog -------------------------------------------------------------

test "list_categories returns 6 seeded categories" {
    cats = list_categories();
    assert len(cats) == 6;
    names = [c["name"] for c in cats];
    assert "Clothing" in names;
    assert "Technology" in names;
}


test "list_products returns 8 seeded products" {
    prods = list_products("");
    assert len(prods) == 8;
}


test "get_product returns variants" {
    p = get_product("prod_001");
    assert p is not None;
    assert p["name"] == "T-Shirt";
    assert len(p["variants"]) == 3;
}


test "get_product returns None for unknown product" {
    p = get_product("prod_does_not_exist");
    assert p is None;
}


test "search_products matches name case-insensitively" {
    results = search_products("shirt");
    names = [p["name"] for p in results];
    assert "T-Shirt" in names;
}


# Users ---------------------------------------------------------------

test "get_profile returns alice" {
    u = get_profile("user_001");
    assert u is not None;
    assert u["username"] == "alice";
}


test "list_addresses for alice returns one default" {
    addrs = list_addresses("user_001");
    assert len(addrs) == 1;
    assert addrs[0]["is_default"];
}


test "list_payment_methods for bob returns Mastercard" {
    pms = list_payment_methods("user_002");
    assert len(pms) == 1;
    assert pms[0]["card_brand"] == "Mastercard";
}


# Cart ----------------------------------------------------------------

test "get_cart for alice returns items dict" {
    cart = get_cart("user_001");
    assert "items" in cart;
    assert "total" in cart;
    assert len(cart["items"]) == 1;
}


test "get_cart for new user has empty items list" {
    cart = get_cart("user_new");
    assert "items" in cart;
    assert len(cart["items"]) == 0;
    assert cart["total"] == 0.0;
}


# Orders --------------------------------------------------------------

test "list_orders for alice returns two seeded orders" {
    orders = list_orders("user_001");
    ids = [o["id"] for o in orders];
    assert "W0000001" in ids;
    assert "W0000004" in ids;
}


test "get_order returns full detail" {
    o = get_order("W0000001");
    assert o is not None;
    assert o["status"] == "pending";
    assert len(o["items"]) == 1;
    assert len(o["payments"]) == 1;
}


# Reviews -------------------------------------------------------------

test "list_reviews returns two reviews for T-Shirt" {
    out = list_reviews("prod_001");
    assert out["count"] == 2;
}


test "list_reviews returns empty for product with no reviews" {
    out = list_reviews("prod_002");
    assert out["count"] == 0;
}

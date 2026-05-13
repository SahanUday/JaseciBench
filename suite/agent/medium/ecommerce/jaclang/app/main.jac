"""E-commerce app entry point.

Server endpoints (def:pub) are registered here, then the client section
opens with `to cl:` and mounts the `Shell` component. Seeding happens
lazily on first endpoint call (services.catalog.ensure_seeded).
"""

import from seed { seed_catalog }
import from services.catalog { list_categories, list_products, get_product, search_products }
import from services.users {
    list_users, get_profile, list_addresses, list_payment_methods,
    add_address, update_address, delete_address,
}
import from services.reviews { list_reviews, add_review, product_review_summary }
import from services.cart { get_cart, add_to_cart, update_cart_item, remove_from_cart, clear_cart, checkout }
import from services.orders {
    list_orders, get_order, cancel_order, update_order_status,
    return_items, modify_order_items, update_order_address,
    most_purchased_products,
}


cl import "./global.css";

to cl:

import from .frontend { Shell }


def:pub app() -> JsxElement {
    return <Shell />;
}

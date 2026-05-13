"""Cart service: view, mutate, and checkout the shopping cart."""

import from datetime { datetime }
import from models { CartItem, Order, OrderItem, Payment, Variant }
import from services.catalog { find_variant, ensure_seeded }
import from services.users { find_user, find_payment_method }


def find_cart_item(cart_item_id: str) -> CartItem | None {
    for ci in [root() -->][?:CartItem] {
        if ci.id == cart_item_id {
            return ci;
        }
    }
    return None;
}


def cart_item_dict(ci: CartItem, v: Variant) -> dict {
    return {
        "id": ci.id,
        "variant_id": v.id,
        "quantity": ci.quantity,
        "price": v.price,
        "subtotal": v.price * ci.quantity,
        "color": v.color,
        "size": v.size,
        "stock_qty": v.stock_qty,
    };
}


def:pub get_cart(user_id: str) -> dict {
    ensure_seeded();
    items = [];
    total = 0.0;
    for ci in [root() -->][?:CartItem] {
        if ci.user_id != user_id {
            continue;
        }
        v = find_variant(ci.variant_id);
        if v is None {
            continue;
        }
        items.append(cart_item_dict(ci, v));
        total = total + (v.price * ci.quantity);
    }
    shipping = 5.99 if total > 0.0 else 0.0;
    grand_total = round(total + shipping, 2);
    return {"items": items, "total": total, "count": len(items), "shipping": shipping, "grand_total": grand_total};
}


def:pub cart_total_quantity(user_id: str) -> int {
    total_qty = 0;
    for ci in [root() -->][?:CartItem] {
        if ci.user_id == user_id {
            total_qty = total_qty + ci.quantity;
        }
    }
    return total_qty;
}


def:pub add_to_cart(user_id: str, variant_id: str, quantity: int = 1) -> dict {
    ensure_seeded();
    if quantity < 1 {
        return {"error": "Quantity must be at least 1", "status": 400};
    }
    v = find_variant(variant_id);
    if v is None {
        return {"error": "Variant not found", "status": 404};
    }

    existing_qty = 0;
    for ci in [root() -->][?:CartItem] {
        if ci.user_id == user_id and ci.variant_id == variant_id {
            existing_qty = ci.quantity;
            break;
        }
    }

    if v.stock_qty < (existing_qty + quantity) {
        return {"error": "Insufficient stock", "status": 400};
    }

    for ci in [root() -->][?:CartItem] {
        if ci.user_id == user_id and ci.variant_id == variant_id {
            ci.quantity = ci.quantity + quantity;
            return {"id": ci.id, "variant_id": ci.variant_id, "quantity": ci.quantity};
        }
    }

    next_id = "ci_" + str(len([root() -->][?:CartItem]) + 1).zfill(3);
    new_ci = CartItem(id=next_id, user_id=user_id, variant_id=variant_id, quantity=quantity);
    root() ++> new_ci;
    return {"id": new_ci.id, "variant_id": new_ci.variant_id, "quantity": new_ci.quantity};
}


def:pub update_cart_item(cart_item_id: str, quantity: int) -> dict {
    ci = find_cart_item(cart_item_id);
    if ci is None {
        return {"error": "Cart item not found", "status": 404};
    }
    if quantity < 1 {
        del ci;
        return {"deleted": cart_item_id};
    }
    v = find_variant(ci.variant_id);
    if v is not None and v.stock_qty < quantity {
        return {"error": "Insufficient stock", "status": 400};
    }
    ci.quantity = quantity;
    return {"id": ci.id, "quantity": ci.quantity};
}


def:pub cart_replace_variant(cart_item_id: str, new_variant_id: str) -> dict {
    ci = find_cart_item(cart_item_id);
    if ci is None {
        return {"error": "Cart item not found", "status": 404};
    }
    v = find_variant(new_variant_id);
    if v is None {
        return {"error": "Variant not found", "status": 404};
    }
    ci.variant_id = new_variant_id;
    return cart_item_dict(ci, v);
}


def:pub remove_from_cart(cart_item_id: str) -> dict {
    ci = find_cart_item(cart_item_id);
    if ci is None {
        return {"error": "Cart item not found", "status": 404};
    }
    del ci;
    return {"deleted": cart_item_id};
}


def:pub clear_cart(user_id: str) -> dict {
    removed = 0;
    for ci in [root() -->][?:CartItem] {
        if ci.user_id == user_id {
            del ci;
            removed = removed + 1;
        }
    }
    return {"cleared": removed};
}


def:pub checkout(
    user_id: str,
    payment_method_id: str,
    shipping_address1: str,
    shipping_city: str,
    shipping_state: str,
    shipping_zip: str,
    shipping_address2: str = "",
    shipping_country: str = "USA",
) -> dict {
    ensure_seeded();
    u = find_user(user_id);
    if u is None {
        return {"error": "User not found", "status": 404};
    }

    pm = find_payment_method(user_id, payment_method_id);
    if pm is None {
        return {"error": "Payment method not found", "status": 404};
    }

    cart_items = [ci for ci in [root() -->][?:CartItem] if ci.user_id == user_id];
    if not cart_items {
        return {"error": "Cart is empty", "status": 400};
    }

    total = 0.0;
    resolved_variants: list[Variant] = [];
    resolved_qtys: list[int] = [];
    for ci in cart_items {
        v = find_variant(ci.variant_id);
        if v is None {
            return {"error": "Variant " + ci.variant_id + " not found", "status": 400};
        }
        if v.stock_qty < ci.quantity {
            return {"error": "Insufficient stock for variant " + v.id, "status": 400};
        }
        resolved_variants.append(v);
        resolved_qtys.append(ci.quantity);
        total = total + (v.price * ci.quantity);
    }

    order_count = len([root() -->][?:Order]) + 1;
    order_id = "W" + str(order_count).zfill(7);
    now_str = str(datetime.now());

    order = Order(
        id=order_id,
        user_id=user_id,
        status="pending",
        shipping_address1=shipping_address1,
        shipping_address2=shipping_address2,
        shipping_city=shipping_city,
        shipping_state=shipping_state,
        shipping_zip=shipping_zip,
        shipping_country=shipping_country,
        created_at=now_str,
    );
    root() ++> order;

    for idx in range(len(resolved_variants)) {
        v = resolved_variants[idx];
        qty = resolved_qtys[idx];
        v.stock_qty = v.stock_qty - qty;
        oi_id = "oi_" + order_id + "_" + str(idx + 1);
        order ++> OrderItem(
            id=oi_id,
            quantity=qty,
            price_snapshot=v.price,
            variant_id=v.id,
        );
    }

    total_rounded = int(total * 100) / 100.0;
    pay_id = "pay_" + order_id;
    order ++> Payment(
        id=pay_id,
        amount=total_rounded,
        transaction_type="payment",
        payment_method_id=payment_method_id,
        created_at=now_str,
    );

    for ci in cart_items {
        del ci;
    }

    return {"order_id": order_id, "total": total_rounded, "status": "pending"};
}

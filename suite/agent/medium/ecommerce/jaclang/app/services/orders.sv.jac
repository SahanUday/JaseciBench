
import from datetime { datetime }
import from models { Order, OrderItem, Payment, Variant, UserProfile }
import from services.catalog { ensure_seeded, find_variant }
import from services.users { find_payment_method, user_dict, find_user }


def find_order(order_id: str) -> Order | None {
    for o in [root() -->][?:Order] {
        if o.id == order_id {
            return o;
        }
    }
    return None;
}


def order_dict(o: Order, include_items: bool = True) -> dict {
    if not include_items {
        total_paid = 0.0;
        for pay in [o -->][?:Payment] {
            amt = float(str(pay.amount));
            if pay.transaction_type == "payment" {
                total_paid = total_paid + amt;
            }
            if pay.transaction_type == "refund" {
                total_paid = total_paid - amt;
            }
        }
        total_paid = int(total_paid * 100) / 100.0;
        return {
            "id": o.id,
            "user_id": o.user_id,
            "status": o.status,
            "shipping_address1": o.shipping_address1,
            "shipping_address2": o.shipping_address2,
            "shipping_city": o.shipping_city,
            "shipping_state": o.shipping_state,
            "shipping_zip": o.shipping_zip,
            "shipping_country": o.shipping_country,
            "created_at": o.created_at,
            "item_count": len([o -->][?:OrderItem]),
            "total_paid": total_paid,
        };
    }
    items = [
        {
            "id": oi.id,
            "quantity": oi.quantity,
            "price_snapshot": oi.price_snapshot,
            "variant_id": oi.variant_id,
            "returned": oi.returned,
            "subtotal": oi.price_snapshot * oi.quantity,
        }
        for oi in [o -->][?:OrderItem]
    ];
    payments = [
        {
            "id": p.id,
            "amount": p.amount,
            "transaction_type": p.transaction_type,
            "payment_method_id": p.payment_method_id,
            "created_at": p.created_at,
        }
        for p in [o -->][?:Payment]
    ];
    return {
        "id": o.id,
        "user_id": o.user_id,
        "status": o.status,
        "shipping_address1": o.shipping_address1,
        "shipping_address2": o.shipping_address2,
        "shipping_city": o.shipping_city,
        "shipping_state": o.shipping_state,
        "shipping_zip": o.shipping_zip,
        "shipping_country": o.shipping_country,
        "created_at": o.created_at,
        "items": items,
        "payments": payments,
        "total": sum([it["subtotal"] for it in items]),
    };
}


def order_list_dict(o: Order) -> dict {
    return {
        "id": o.id,
        "user_id": o.user_id,
        "status": o.status,
        "shipping_address1": o.shipping_address1,
        "shipping_address2": o.shipping_address2,
        "shipping_city": o.shipping_city,
        "shipping_state": o.shipping_state,
        "shipping_zip": o.shipping_zip,
        "shipping_country": o.shipping_country,
        "created_at": o.created_at,
        "item_count": len([o -->][?:OrderItem]),
    };
}


def find_order_item(o: Order, oi_id: str) -> OrderItem | None {
    for oi in [o -->][?:OrderItem] {
        if oi.id == oi_id {
            return oi;
        }
    }
    return None;
}


def:pub list_orders(
    user_id: str = "",
    from_date: str = "",
    to_date: str = "",
    status: str = "",
) -> list[dict] {
    ensure_seeded();
    orders = [root() -->][?:Order];
    if user_id {
        orders = [o for o in orders if o.user_id == user_id];
    }
    if from_date {
        orders = [o for o in orders if o.created_at >= from_date];
    }
    if to_date {
        orders = [o for o in orders if o.created_at <= to_date];
    }
    if status {
        orders = [o for o in orders if o.status == status];
    }
    return [order_dict(o, include_items=False) for o in orders];
}


def:pub get_order(order_id: str) -> dict | None {
    ensure_seeded();
    o = find_order(order_id);
    if o is None {
        return None;
    }
    return order_dict(o);
}


def:pub pending_order_count() -> int {
    ensure_seeded();
    return len([o for o in [root() -->][?:Order] if o.status == "pending"]);
}


def:pub recent_orders(limit: int = 10) -> list[dict] {
    ensure_seeded();

    if limit < 0 {
        return [{"error": "limit must be non-negative", "status": 400}];
    }

    orders = [order_list_dict(o) for o in [root() -->][?:Order]];

    # Sort newest-first by created_at (stored as string).
    # (Avoid higher-order sort overload issues by doing a simple selection pass.)
    sorted_orders = [];
    for _i in range(len(orders)) {
        best_idx = 0;
        for j in range(len(orders)) {
            if orders[j]["created_at"] > orders[best_idx]["created_at"] {
                best_idx = j;
            }
        }
        sorted_orders.append(orders.pop(best_idx));
    }
    orders = sorted_orders;

    if limit == 0 {
        return [];
    }

    return orders[:limit];
}


def:pub user_with_most_orders() -> str {
    ensure_seeded();

    counts: dict = {};
    for o in [root() -->][?:Order] {
        uid = o.user_id;
        if not uid {
            continue;
        }
        if uid not in counts {
            counts[uid] = 0;
        }
        counts[uid] = counts[uid] + 1;
    }

    best_uid = "";
    best_cnt = -1;
    for uid in counts {
        cnt = int(counts[uid]);
        if cnt > best_cnt {
            best_cnt = cnt;
            best_uid = str(uid);
        }
    }

    return best_uid;
}


def:pub cancel_order(order_id: str) -> dict {
    ensure_seeded();
    o = find_order(order_id);
    if o is None {
        return {"error": "Order not found", "status": 404};
    }

    if o.status != "pending" {
        return {"error": "Only pending orders can be cancelled (current status: " + o.status + ")", "status": 400};
    }

    # Restore reserved stock back to inventory before issuing refunds.
    for oi in [o -->][?:OrderItem] {
        v = find_variant(oi.variant_id);
        if v is not None {
            v.stock_qty = v.stock_qty + oi.quantity;
        }
    }

    now_str = str(datetime.now());
    refund_seq = 0;
    for pay in [o -->][?:Payment] {
        if pay.transaction_type == "payment" {
            refund_seq = refund_seq + 1;
            o ++> Payment(
                id="refund_" + o.id + "_" + str(refund_seq),
                amount=pay.amount,
                transaction_type="refund",
                payment_method_id=pay.payment_method_id,
                created_at=now_str,
            );
        }
    }

    o.status = "cancelled";
    return order_dict(o);
}


def:pub return_items(order_id: str, item_ids: list[str], payment_method_id: str) -> dict {
    ensure_seeded();
    o = find_order(order_id);
    if o is None {
        return {"error": "Order not found", "status": 404};
    }
    if o.status != "delivered" {
        return {"error": "Only delivered orders can be returned (current status: " + o.status + ")", "status": 400};
    }

    items_to_return: list[OrderItem] = [];
    for oi_id in item_ids {
        oi = find_order_item(o, oi_id);
        if oi is None {
            return {"error": "Order item " + oi_id + " not found in order", "status": 404};
        }
        if oi.returned {
            return {"error": "Order item " + oi_id + " is already returned", "status": 400};
        }
        items_to_return.append(oi);
    }

    refund_total = 0.0;
    for oi in items_to_return {
        oi.returned = True;
        v = find_variant(oi.variant_id);
        if v is not None {
            v.stock_qty = v.stock_qty + oi.quantity;
        }
        refund_total = refund_total + (oi.price_snapshot * oi.quantity);
    }

    pm = find_payment_method(o.user_id, payment_method_id);
    if pm is None {
        return {"error": "Payment method not found", "status": 404};
    }

    now_str = str(datetime.now());
    o ++> Payment(
        id="refund_" + o.id + "_manual_" + now_str,
        amount=int(refund_total * 100) / 100.0,
        transaction_type="refund",
        payment_method_id=payment_method_id,
        created_at=now_str,
    );

    return order_dict(o);
}


def:pub modify_order_items(order_id: str, changes: list[dict]) -> dict {
    ensure_seeded();
    o = find_order(order_id);
    if o is None {
        return {"error": "Order not found", "status": 404};
    }

    if o.status != "pending" {
        return {"error": "Only pending orders can be modified (current status: " + o.status + ")", "status": 400};
    }

    for ch in changes {
        oi_id = str(ch.get("id", ""));
        new_qty = int(ch.get("quantity", 0));
        if not oi_id {
            continue;
        }
        oi = find_order_item(o, oi_id);
        if oi is None {
            return {"error": "Order item " + oi_id + " not found in order", "status": 404};
        }
        if new_qty <= 0 {
            return {"error": "Quantity must be > 0", "status": 400};
        }

        v = find_variant(oi.variant_id);
        if v is None {
            return {"error": "Variant not found", "status": 404};
        }

        # Adjust stock by delta.
        delta = new_qty - oi.quantity;
        if delta > 0 {
            if v.stock_qty < delta {
                return {"error": "Insufficient stock", "status": 400};
            }
            v.stock_qty = v.stock_qty - delta;
        }
        if delta < 0 {
            v.stock_qty = v.stock_qty + (-delta);
        }
        oi.quantity = new_qty;
    }

    return order_dict(o);
}


def:pub update_order_address(
    order_id: str,
    shipping_address1: str = "",
    shipping_address2: str = "",
    shipping_city: str = "",
    shipping_state: str = "",
    shipping_zip: str = "",
    shipping_country: str = "",
) -> dict {
    ensure_seeded();
    o = find_order(order_id);
    if o is None {
        return {"error": "Order not found", "status": 404};
    }

    if shipping_address1 {
        o.shipping_address1 = shipping_address1;
    }
    if shipping_address2 {
        o.shipping_address2 = shipping_address2;
    }
    if shipping_city {
        o.shipping_city = shipping_city;
    }
    if shipping_state {
        o.shipping_state = shipping_state;
    }
    if shipping_zip {
        o.shipping_zip = shipping_zip;
    }
    if shipping_country {
        o.shipping_country = shipping_country;
    }

    return order_dict(o);
}


def:pub update_order_status(order_id: str, new_status: str) -> dict {
    ensure_seeded();
    o = find_order(order_id);
    if o is None {
        return {"error": "Order not found", "status": 404};
    }

    o.status = new_status;
    return order_dict(o);
}


def:pub get_user_spend(user_id: str) -> dict {
    ensure_seeded();
    orders = [o for o in [root() -->][?:Order] if o.user_id == user_id];
    total_paid = 0.0;
    for o in orders {
        for pay in [o -->][?:Payment] {
            amt = float(str(pay.amount));
            if pay.transaction_type == "payment" {
                total_paid = total_paid + amt;
            }
            if pay.transaction_type == "refund" {
                total_paid = total_paid - amt;
            }
        }
    }
    total_paid = int(total_paid * 100) / 100.0;
    return {"user_id": user_id, "total_paid": total_paid};
}


def:pub users_with_min_orders(min_count: int) -> list[dict] {
    ensure_seeded();
    users = [root() -->][?:UserProfile];
    res: list[dict] = [];
    for u in users {
        cnt = len([o for o in [root() -->][?:Order] if o.user_id == u.id]);
        if cnt >= min_count {
            res.append(user_dict(u));
        }
    }
    return res;
}


def:pub total_revenue() -> float {
    ensure_seeded();
    rev = 0.0;
    for o in [root() -->][?:Order] {
        for pay in [o -->][?:Payment] {
            amt = float(str(pay.amount));
            if pay.transaction_type == "payment" {
                rev = rev + amt;
            }
            if pay.transaction_type == "refund" {
                rev = rev - amt;
            }
        }
    }
    return int(rev * 100) / 100.0;
}


def:pub customers_by_recent_order() -> list[dict] {
    ensure_seeded();

    # Compute each user's newest order created_at.
    newest_by_user: dict = {};
    for o in [root() -->][?:Order] {
        uid = o.user_id;
        if not uid {
            continue;
        }
        if (uid not in newest_by_user) or (o.created_at > newest_by_user[uid]) {
            newest_by_user[uid] = o.created_at;
        }
    }

    # Exclude users with no orders.
    users: list[UserProfile] = [u for u in [root() -->][?:UserProfile] if u.id in newest_by_user];

    # Sort users by recency descending.
    users = sorted(users, key=lambda u: newest_by_user[str(u["id"])], reverse=True);

    return [
        {
            **user_dict(u),
            "most_recent_order_created_at": newest_by_user[u.id],
        }
        for u in users
    ];
}

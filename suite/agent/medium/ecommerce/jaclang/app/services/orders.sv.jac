"""Orders service: list, view, cancel, return, modify items, update status/address."""

import from datetime { datetime }
import from models { Order, OrderItem, Payment, Variant, UserProfile }
import from services.catalog { ensure_seeded, find_variant }
import from services.users { find_payment_method, user_dict }


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
        for p in [o -->][?:Payment] {
            if p.transaction_type == "payment" {
                total_paid = total_paid + p.amount;
            } elif p.transaction_type == "refund" {
                total_paid = total_paid - p.amount;
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


def find_order_item(o: Order, oi_id: str) -> OrderItem | None {
    for oi in [o -->][?:OrderItem] {
        if oi.id == oi_id {
            return oi;
        }
    }
    return None;
}


def:pub list_orders(user_id: str = "", from_date: str = "", to_date: str = "", status: str = "") -> list[dict] {
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


def:pub cancel_order(order_id: str) -> dict {
    ensure_seeded();
    o = find_order(order_id);
    if o is None {
        return {"error": "Order not found", "status": 404};
    }
    if o.status != "pending" {
        return {"error": "Only pending orders can be cancelled (current status: " + o.status + ")", "status": 400};
    }

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
        if oi.returned == True {
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

    now_str = str(datetime.now());
    refund_seq = len([p for p in [o -->][?:Payment] if p.transaction_type == "refund"]) + 1;
    o ++> Payment(
        id="refund_" + o.id + "_" + str(refund_seq),
        amount=int(refund_total * 100) / 100.0,
        transaction_type="refund",
        payment_method_id=payment_method_id,
        created_at=now_str,
    );

    all_returned = True;
    for oi in [o -->][?:OrderItem] {
        if not oi.returned {
            all_returned = False;
        }
    }
    if all_returned {
        o.status = "returned";
    }

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

    for change in changes {
        oi_id = change["order_item_id"];
        new_variant_id = change["new_variant_id"] if "new_variant_id" in change else "";
        new_quantity = change["new_quantity"] if "new_quantity" in change else 0;

        oi = find_order_item(o, oi_id);
        if oi is None {
            return {"error": "Order item " + oi_id + " not found", "status": 404};
        }

        if new_variant_id and new_variant_id != oi.variant_id {
            new_v = find_variant(new_variant_id);
            if new_v is None {
                return {"error": "Variant " + new_variant_id + " not found", "status": 404};
            }
            qty_needed = new_quantity if new_quantity else oi.quantity;
            if new_v.stock_qty < qty_needed {
                return {"error": "Insufficient stock for variant " + new_variant_id, "status": 400};
            }
            old_v = find_variant(oi.variant_id);
            if old_v is not None {
                old_v.stock_qty = old_v.stock_qty + oi.quantity;
            }
            new_v.stock_qty = new_v.stock_qty - qty_needed;
            oi.variant_id = new_variant_id;
            oi.price_snapshot = new_v.price;
            oi.quantity = qty_needed;
        } elif new_quantity and new_quantity != oi.quantity {
            v = find_variant(oi.variant_id);
            diff = new_quantity - oi.quantity;
            if diff > 0 and v is not None and v.stock_qty < diff {
                return {"error": "Insufficient stock for variant " + oi.variant_id, "status": 400};
            }
            if v is not None {
                v.stock_qty = v.stock_qty - diff;
            }
            oi.quantity = new_quantity;
        }
    }

    new_total = 0.0;
    for oi in [o -->][?:OrderItem] {
        new_total = new_total + (oi.price_snapshot * oi.quantity);
    }
    new_total_rounded = int(new_total * 100) / 100.0;
    for pay in [o -->][?:Payment] {
        if pay.transaction_type == "payment" {
            pay.amount = new_total_rounded;
        }
    }

    return order_dict(o);
}


def:pub update_order_address(order_id: str, address1: str, city: str, state: str, zip_code: str, address2: str = "", country: str = "USA") -> dict {
    ensure_seeded();
    o = find_order(order_id);
    if o is None {
        return {"error": "Order not found", "status": 404};
    }
    if o.status != "pending" {
        return {"error": "Address can only be changed on pending orders (current status: " + o.status + ")", "status": 400};
    }
    o.shipping_address1 = address1;
    o.shipping_address2 = address2;
    o.shipping_city = city;
    o.shipping_state = state;
    o.shipping_zip = zip_code;
    o.shipping_country = country;
    return order_dict(o);
}


def:pub update_order_status(order_id: str, new_status: str) -> dict {
    valid = ["pending", "processed", "shipped", "delivered", "cancelled", "returned"];
    if new_status not in valid {
        return {"error": "Invalid status: " + new_status, "status": 400};
    }
    o = find_order(order_id);
    if o is None {
        return {"error": "Order not found", "status": 404};
    }
    o.status = new_status;
    return {"id": o.id, "status": o.status};
}


def:pub get_user_spend(user_id: str) -> dict {
    ensure_seeded();
    total_paid = 0.0;
    total_refunded = 0.0;
    
    orders = [o for o in [root() -->][?:Order] if o.user_id == user_id];
    
    for o in orders {
        for p in [o -->][?:Payment] {
            if p.transaction_type == "payment" {
                total_paid = total_paid + p.amount;
            } elif p.transaction_type == "refund" {
                total_refunded = total_refunded + p.amount;
            }
        }
    }
    
    net_spent = total_paid - total_refunded;
    
    return {
        "total_paid": total_paid,
        "total_refunded": total_refunded,
        "net_spent": net_spent,
    };
}


def:pub users_with_min_orders(min_count: int) -> list[dict] {
    ensure_seeded();
    result: list[dict] = [];
    for u in [root() -->][?:UserProfile] {
        order_count = len([o for o in [root() -->][?:Order] if o.user_id == u.id]);
        if order_count >= min_count {
            result.append(user_dict(u));
        }
    }
    return result;
}


def:pub total_revenue() -> float {
    ensure_seeded();
    revenue = 0.0;
    
    for o in [root() -->][?:Order] {
        for p in [o -->][?:Payment] {
            if p.transaction_type == "payment" {
                revenue = revenue + p.amount;
            } elif p.transaction_type == "refund" {
                revenue = revenue - p.amount;
            }
        }
    }
    
    return revenue;
}


def:pub customers_by_recent_order() -> list[dict] {
    ensure_seeded();
    
    # Build a map of user_id -> most recent order created_at
    user_recent_order: dict[str, str] = {};
    
    for o in [root() -->][?:Order] {
        if o.user_id not in user_recent_order {
            user_recent_order[o.user_id] = o.created_at;
        } else {
            if o.created_at > user_recent_order[o.user_id] {
                user_recent_order[o.user_id] = o.created_at;
            }
        }
    }
    
    # Get all users who have orders and create tuples (user_dict, recent_order_date)
    user_data: list[tuple[dict, str]] = [];
    for u in [root() -->][?:UserProfile] {
        if u.id in user_recent_order {
            user_data.append((user_dict(u), user_recent_order[u.id]));
        }
    }
    
    # Sort by recent order date descending (most recent first)
    user_data.sort(key=lambda x: x[1], reverse=True);
    
    # Return just the user dicts
    return [ud[0] for ud in user_data];
}


def:pub pending_order_count() -> int {
    ensure_seeded();
    pending_orders = [o for o in [root() -->][?:Order] if o.status == "pending"];
    return len(pending_orders);
}


def:pub user_with_most_orders() -> str {
    ensure_seeded();
    max_count = 0;
    max_user_id = "";
    
    for u in [root() -->][?:UserProfile] {
        order_count = len([o for o in [root() -->][?:Order] if o.user_id == u.id]);
        if order_count > max_count {
            max_count = order_count;
            max_user_id = u.id;
        }
    }
    
    return max_user_id;
}


def:pub recent_orders(limit: int) -> list[dict] {
    ensure_seeded();
    orders = [root() -->][?:Order];
    
    # Sort by created_at descending (newest first)
    orders.sort(key=lambda o: o.created_at, reverse=True);
    
    # Take first limit orders
    recent = orders[:limit];
    
    return [order_dict(o, include_items=False) for o in recent];
}

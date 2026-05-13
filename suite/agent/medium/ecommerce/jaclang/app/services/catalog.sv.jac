"""Catalog service: categories, products, variants, search."""

import from models { Category, Product, Variant, Review, Order, OrderItem }
import from seed { seed_catalog }


def ensure_seeded() -> None {
    if not [root() -->][?:Category] {
        seed_catalog();
    }
}


def category_dict(c: Category) -> dict {
    product_count = 0;
    for p in [root() -->][?:Product] {
        if p.category_id == c.id and p.active {
            product_count += 1;
        }
    }
    return {
        "id": c.id,
        "name": c.name,
        "description": c.description,
        "product_count": product_count,
    };
}


def variant_dict(v: Variant) -> dict {
    return {
        "id": v.id,
        "price": v.price,
        "color": v.color,
        "size": v.size,
        "material": v.material,
        "stock_qty": v.stock_qty,
    };
}


def product_dict(p: Product, include_variants: bool = True) -> dict {
    # Calculate review stats
    reviews = [r for r in [p -->][?:Review]];
    review_count = len(reviews);
    average_rating = 0.0;
    if review_count > 0 {
        total_rating = 0;
        for r in reviews {
            total_rating = total_rating + r.rating;
        }
        average_rating = round(total_rating / review_count, 2);
    }
    
    # Calculate total stock across all variants
    variant_objs = [v for v in [p -->][?:Variant]];
    total_stock = 0;
    for v in variant_objs {
        total_stock = total_stock + v.stock_qty;
    }
    
    if not include_variants {
        return {
            "id": p.id,
            "name": p.name,
            "description": p.description,
            "category_id": p.category_id,
            "active": p.active,
            "average_rating": average_rating,
            "review_count": review_count,
            "total_stock": total_stock,
        };
    }
    variants = [variant_dict(v) for v in variant_objs];
    min_price = 0.0;
    if variants {
        min_price = min([v["price"] for v in variants]);
    }
    return {
        "id": p.id,
        "name": p.name,
        "description": p.description,
        "category_id": p.category_id,
        "active": p.active,
        "variants": variants,
        "min_price": min_price,
        "average_rating": average_rating,
        "review_count": review_count,
        "total_stock": total_stock,
    };
}


def find_variant(variant_id: str) -> Variant | None {
    for p in [root() -->][?:Product] {
        for v in [p -->][?:Variant] {
            if v.id == variant_id {
                return v;
            }
        }
    }
    return None;
}


def find_product(product_id: str) -> Product | None {
    for p in [root() -->][?:Product] {
        if p.id == product_id {
            return p;
        }
    }
    return None;
}


def:pub list_categories() -> list[dict] {
    ensure_seeded();
    return [category_dict(c) for c in [root() -->][?:Category]];
}


def:pub list_products(category_id: str = "") -> list[dict] {
    ensure_seeded();
    products = [root() -->][?:Product];
    if category_id {
        return [product_dict(p) for p in products if p.active and p.category_id == category_id];
    }
    return [product_dict(p) for p in products if p.active];
}


def:pub get_product(product_id: str) -> dict | None {
    ensure_seeded();
    p = find_product(product_id);
    if p is None {
        return None;
    }
    if not p.active {
        return None;
    }
    return product_dict(p);
}


def:pub search_products(q: str = "", category_id: str = "", min_price: float = 0.0, max_price: float = 0.0) -> list[dict] {
    ensure_seeded();
    q_lower = q.lower();
    matches = [];
    for p in [root() -->][?:Product] {
        if not p.active {
            continue;
        }
        # Filter by text query if provided
        if q and not (q_lower in p.name.lower() or q_lower in p.description.lower()) {
            continue;
        }
        # Filter by category if provided
        if category_id and p.category_id != category_id {
            continue;
        }
        # Filter by price range if provided
        if min_price > 0.0 or max_price > 0.0 {
            variants = [v for v in [p -->][?:Variant]];
            if variants {
                min_variant_price = min([v.price for v in variants]);
                if min_price > 0.0 and min_variant_price < min_price {
                    continue;
                }
                if max_price > 0.0 and min_variant_price > max_price {
                    continue;
                }
            } else {
                # Skip products with no variants if price filtering is active
                continue;
            }
        }
        matches.append(product_dict(p));
    }
    return matches;
}


def:pub top_rated_products(limit: int) -> list[dict] {
    ensure_seeded();
    # Get all active products with their product dicts
    products = [product_dict(p) for p in [root() -->][?:Product] if p.active];
    # Sort by average_rating descending (highest first)
    sorted_products = sorted(products, key=lambda p: p["average_rating"], reverse=True);
    # Return truncated to limit
    return sorted_products[0:limit];
}


def:pub update_variant_price(variant_id: str, new_price: float) -> dict {
    ensure_seeded();
    v = find_variant(variant_id);
    if v is None {
        return {"error": "Variant not found", "status": 404};
    }
    if new_price < 0.0 {
        return {"error": "Price cannot be negative", "status": 400};
    }
    v.price = new_price;
    return variant_dict(v);
}


def:pub list_out_of_stock_products() -> list[dict] {
    ensure_seeded();
    out_of_stock = [];
    for p in [root() -->][?:Product] {
        if not p.active {
            continue;
        }
        variants = [v for v in [p -->][?:Variant]];
        if not variants {
            # Product with no variants is not considered out of stock
            continue;
        }
        # Check if ALL variants are out of stock
        all_out_of_stock = True;
        for v in variants {
            if v.stock_qty > 0 {
                all_out_of_stock = False;
                break;
            }
        }
        if all_out_of_stock {
            out_of_stock.append(product_dict(p));
        }
    }
    return out_of_stock;
}


def:pub deactivate_product(product_id: str) -> dict | None {
    ensure_seeded();
    p = find_product(product_id);
    if p is None {
        return None;
    }
    p.active = False;
    return product_dict(p, include_variants=False);
}


def:pub low_stock_products(threshold: int) -> list[dict] {
    ensure_seeded();
    low_stock = [];
    for p in [root() -->][?:Product] {
        if not p.active {
            continue;
        }
        variants = [v for v in [p -->][?:Variant]];
        if not variants {
            # Product with no variants is skipped
            continue;
        }
        # Check if ANY variant has stock_qty < threshold
        has_low_stock = False;
        for v in variants {
            if v.stock_qty < threshold {
                has_low_stock = True;
                break;
            }
        }
        if has_low_stock {
            low_stock.append(product_dict(p));
        }
    }
    return low_stock;
}


def:pub search_by_name(q: str) -> list[dict] {
    ensure_seeded();
    q_lower = q.lower();
    matches = [];
    for p in [root() -->][?:Product] {
        if not p.active {
            continue;
        }
        if q_lower in p.name.lower() {
            matches.append(product_dict(p));
        }
    }
    return matches;
}


def:pub most_purchased_products(limit: int) -> list[dict] {
    ensure_seeded();
    
    # Build a map of product_id -> total_quantity from OrderItems
    product_sales: dict = {};
    
    # Get all orders and iterate through their items
    for o in [root() -->][?:Order] {
        for oi in [o -->][?:OrderItem] {
            # Find the variant to get its product
            v = find_variant(oi.variant_id);
            if v is None {
                continue;
            }
            
            # Find the product that owns this variant
            product_id = "";
            for p in [root() -->][?:Product] {
                for pv in [p -->][?:Variant] {
                    if pv.id == v.id {
                        product_id = p.id;
                        break;
                    }
                }
                if product_id {
                    break;
                }
            }
            
            if product_id {
                if product_id not in product_sales {
                    product_sales[product_id] = 0;
                }
                product_sales[product_id] = product_sales[product_id] + oi.quantity;
            }
        }
    }
    
    # Create list of (product_id, quantity) tuples
    product_qty_list: list[tuple[str, int]] = [];
    for product_id in product_sales.keys() {
        product_qty_list.append((product_id, product_sales[product_id]));
    }
    
    # Sort by quantity in descending order (bubble sort)
    for i in range(len(product_qty_list)) {
        for j in range(len(product_qty_list) - i - 1) {
            if product_qty_list[j][1] < product_qty_list[j + 1][1] {
                temp = product_qty_list[j];
                product_qty_list[j] = product_qty_list[j + 1];
                product_qty_list[j + 1] = temp;
            }
        }
    }
    
    # Return top N products as dicts
    result: list[dict] = [];
    for i in range(min(limit, len(product_qty_list))) {
        product_id: str = product_qty_list[i][0];
        p = find_product(product_id);
        if p is not None and p.active {
            result.append(product_dict(p));
        }
    }
    
    return result;
}


def:pub average_product_price() -> float {
    ensure_seeded();
    
    total_price = 0.0;
    variant_count = 0;
    
    # Iterate through all active products
    for p in [root() -->][?:Product] {
        if not p.active {
            continue;
        }
        
        # Sum up all variant prices for this product
        for v in [p -->][?:Variant] {
            total_price = total_price + v.price;
            variant_count = variant_count + 1;
        }
    }
    
    # Return average (0.0 if no variants)
    if variant_count == 0 {
        return 0.0;
    }
    
    return round(total_price / variant_count, 2);
}


def:pub products_without_reviews() -> list[dict] {
    ensure_seeded();
    result = [];
    for p in [root() -->][?:Product] {
        if not p.active {
            continue;
        }
        # Check if product has any reviews
        reviews = [r for r in [p -->][?:Review]];
        if len(reviews) == 0 {
            result.append(product_dict(p));
        }
    }
    return result;
}

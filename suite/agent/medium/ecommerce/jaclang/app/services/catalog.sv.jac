"""Catalog service: categories, products, variants, search."""

import from models { Category, Product, Variant, Review, OrderItem }
import from seed { seed_catalog }


def ensure_seeded() -> None {
    if not [root() -->][?:Category] {
        seed_catalog();
    }
}


def category_dict(c: Category) -> dict {
    product_count = len([p for p in [root() -->][?:Product] if p.category_id == c.id and p.active]);
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
    reviews = [p -->][?:Review];
    review_count = len(reviews);
    average_rating = round(sum([r.rating for r in reviews]) / review_count, 2) if review_count > 0 else 0.0;
    variant_nodes = [p -->][?:Variant];
    total_stock = sum([v.stock_qty for v in variant_nodes]);
    
    if not include_variants {
        return {
            "id": p.id,
            "name": p.name,
            "description": p.description,
            "category_id": p.category_id,
            "active": p.active,
            "review_count": review_count,
            "average_rating": average_rating,
            "total_stock": total_stock,
        };
    }
    variants = [variant_dict(v) for v in variant_nodes];
    min_price = min([v.price for v in variant_nodes]) if variant_nodes else 0.0;
    return {
        "id": p.id,
        "name": p.name,
        "description": p.description,
        "category_id": p.category_id,
        "active": p.active,
        "variants": variants,
        "min_price": min_price,
        "review_count": review_count,
        "average_rating": average_rating,
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


def:pub product_count() -> int {
    ensure_seeded();
    products = [root() -->][?:Product];
    return len([p for p in products if p.active]);
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


def:pub search_by_name(q: str) -> list[dict] {
    ensure_seeded();
    q_lower = q.lower();
    matches = [];
    for p in [root() -->][?:Product] {
        if not p.active {
            continue;
        }
        # Only filter by name
        if q_lower in p.name.lower() {
            matches.append(product_dict(p));
        }
    }
    return matches;
}


def:pub search_products(q: str = "", category_id: str = "", min_price: float = 0.0, max_price: float = 0.0) -> list[dict] {
    ensure_seeded();
    q_lower = q.lower() if q else "";
    matches = [];
    for p in [root() -->][?:Product] {
        if not p.active {
            continue;
        }
        # Text filter
        if q and not (q_lower in p.name.lower() or q_lower in p.description.lower()) {
            continue;
        }
        # Category filter
        if category_id and p.category_id != category_id {
            continue;
        }
        # Price filters
        variants = [p -->][?:Variant];
        if variants {
            product_min_price = min([v.price for v in variants]);
            if min_price > 0.0 and product_min_price < min_price {
                continue;
            }
            if max_price > 0.0 and product_min_price > max_price {
                continue;
            }
        }
        matches.append(product_dict(p));
    }
    return matches;
}


def:pub top_rated_products(limit: int) -> list[dict] {
    ensure_seeded();
    products = [root() -->][?:Product];
    active_products = [product_dict(p) for p in products if p.active];
    # Sort by average_rating descending using bubble sort
    n = len(active_products);
    for i in range(n) {
        for j in range(0, n - i - 1) {
            if active_products[j]["average_rating"] < active_products[j + 1]["average_rating"] {
                temp = active_products[j];
                active_products[j] = active_products[j + 1];
                active_products[j + 1] = temp;
            }
        }
    }
    return active_products[:limit];
}


def:pub update_variant_price(variant_id: str, new_price: float) -> dict {
    ensure_seeded();
    
    # Validate price is not negative
    if new_price < 0.0 {
        return {"error": "Price cannot be negative", "status": 400};
    }
    
    # Find the variant
    v = find_variant(variant_id);
    if v is None {
        return {"error": "Variant not found", "status": 404};
    }
    
    # Update the price
    v.price = new_price;
    
    # Return the updated variant
    return variant_dict(v);
}


def:pub deactivate_product(product_id: str) -> dict {
    ensure_seeded();
    
    # Find the product
    p = find_product(product_id);
    if p is None {
        return {"error": "Product not found", "status": 404};
    }
    
    # Deactivate the product
    p.active = False;
    
    # Return the updated product
    return product_dict(p);
}


def:pub list_out_of_stock_products() -> list[dict] {
    ensure_seeded();
    out_of_stock = [];
    for p in [root() -->][?:Product] {
        if not p.active {
            continue;
        }
        variants = [p -->][?:Variant];
        # Product is out of stock if it has variants and all have stock_qty == 0
        if variants and all([v.stock_qty == 0 for v in variants]) {
            out_of_stock.append(product_dict(p));
        }
    }
    return out_of_stock;
}


def:pub low_stock_products(threshold: int) -> list[dict] {
    ensure_seeded();
    low_stock = [];
    for p in [root() -->][?:Product] {
        if not p.active {
            continue;
        }
        variants = [p -->][?:Variant];
        # Product is low stock if it has any variant with stock_qty < threshold
        if variants and any([v.stock_qty < threshold for v in variants]) {
            low_stock.append(product_dict(p));
        }
    }
    return low_stock;
}


"""Find the product that owns the given variant."""
def find_product_by_variant(variant_id: str) -> Product | None {
    for p in [root -->][?:Product] {
        for v in [p -->][?:Variant] {
            if v.id == variant_id {
                return p;
            }
        }
    }
    return None;
}

"""Return products ranked by total units sold across all OrderItems."""
def:pub most_purchased_products(limit: int) -> list[dict] {
    ensure_seeded();
    
    # Build a dict mapping product_id to total quantity sold
    product_quantities: dict[str, int] = {};
    
    # Iterate through all OrderItems
    for oi in [root -->][?:OrderItem] {
        # Find the product for this order item's variant
        product = find_product_by_variant(oi.variant_id);
        if product is not None {
            if product.id not in product_quantities {
                product_quantities[product.id] = 0;
            }
            product_quantities[product.id] = product_quantities[product.id] + oi.quantity;
        }
    }
    
    # Convert to list of (product_id, quantity) tuples and sort by quantity descending
    product_list = [(pid, qty) for (pid, qty) in product_quantities.items()];
    
    # Bubble sort by quantity descending
    n = len(product_list);
    for i in range(n) {
        for j in range(0, n - i - 1) {
            if product_list[j][1] < product_list[j + 1][1] {
                temp = product_list[j];
                product_list[j] = product_list[j + 1];
                product_list[j + 1] = temp;
            }
        }
    }
    
    # Take top limit and convert to product dicts
    result = [];
    for (pid, qty) in product_list[:limit] {
        product = find_product(pid);
        if product is not None {
            prod_dict = product_dict(product, include_variants=False);
            prod_dict["units_sold"] = qty;
            result.append(prod_dict);
        }
    }
    
    return result;
}


def:pub average_product_price() -> float {
    ensure_seeded();
    
    # Collect all variant prices from active products
    all_prices = [];
    for p in [root() -->][?:Product] {
        if not p.active {
            continue;
        }
        variants = [p -->][?:Variant];
        for v in variants {
            all_prices.append(v.price);
        }
    }
    
    # Calculate mean
    if len(all_prices) == 0 {
        return 0.0;
    }
    return sum(all_prices) / len(all_prices);
}


def:pub products_without_reviews() -> list[dict] {
    ensure_seeded();
    result = [];
    for p in [root() -->][?:Product] {
        if not p.active {
            continue;
        }
        # Check if product has zero reviews
        if len([p -->][?:Review]) == 0 {
            result.append(product_dict(p));
        }
    }
    return result;
}

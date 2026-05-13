"""Catalog service: categories, products, variants, search."""

import from models { Category, Product, Variant, Review }
import from seed { seed_catalog }


def ensure_seeded() -> None {
    if not [root() -->][?:Category] {
        seed_catalog();
    }
}


def category_dict(c: Category) -> dict {
    product_count = sum([1 for p in [root() -->][?:Product] if p.category_id == c.id and p.active]);
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
    reviews = [r for r in [p -->][?:Review]];
    review_count = len(reviews);
    average_rating = round(sum([r.rating for r in reviews]) / review_count, 2) if review_count > 0 else 0.0;
    
    variants_list = [p -->][?:Variant];
    total_stock = sum([v.stock_qty for v in variants_list]);
    
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
    variants = [variant_dict(v) for v in variants_list];
    min_price = min([v.price for v in variants_list]) if variants_list else 0.0;
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


def:pub list_out_of_stock_products() -> list[dict] {
    ensure_seeded();
    out_of_stock = [];
    for p in [root() -->][?:Product] {
        if not p.active {
            continue;
        }
        variants = [v for v in [p -->][?:Variant]];
        # Product is out of stock if it has variants and ALL have stock_qty == 0
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
        variants = [v for v in [p -->][?:Variant]];
        # Product is low stock if it has any variant with stock_qty < threshold
        if any([v.stock_qty < threshold for v in variants]) {
            low_stock.append(product_dict(p));
        }
    }
    return low_stock;
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
        # Name-only search
        if q_lower in p.name.lower() {
            matches.append(product_dict(p));
        }
    }
    return matches;
}


def:pub search_products(q: str = "", category_id: str = "", min_price: float = 0.0, max_price: float = 0.0) -> list[dict] {
    ensure_seeded();
    q_lower = q.lower();
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
        # Price filter
        variants = [v for v in [p -->][?:Variant]];
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
    product_dicts = [product_dict(p) for p in products if p.active];
    # Sort by average_rating descending
    sorted_products = sorted(product_dicts, key=lambda p: p["average_rating"], reverse=True);
    return sorted_products[:limit];
}


def:pub update_variant_price(variant_id: str, new_price: float) -> dict {
    ensure_seeded();
    # Validate price
    if new_price < 0.0 {
        return {"error": "Price cannot be negative", "status": 400};
    }
    # Find variant
    v = find_variant(variant_id);
    if v is None {
        return {"error": "Variant not found", "status": 404};
    }
    # Update price
    v.price = new_price;
    return variant_dict(v);
}


def:pub deactivate_product(product_id: str) -> dict {
    ensure_seeded();
    # Find product
    p = find_product(product_id);
    if p is None {
        return {"error": "Product not found", "status": 404};
    }
    # Deactivate
    p.active = False;
    return product_dict(p);
}


def:pub product_count() -> int {
    ensure_seeded();
    return sum([1 for p in [root() -->][?:Product] if p.active]);
}


def:pub average_product_price() -> float {
    ensure_seeded();
    all_prices = [];
    for p in [root() -->][?:Product] {
        if not p.active {
            continue;
        }
        for v in [p -->][?:Variant] {
            all_prices.append(v.price);
        }
    }
    if len(all_prices) == 0 {
        return 0.0;
    }
    return round(sum(all_prices) / len(all_prices), 2);
}


def:pub products_without_reviews() -> list[dict] {
    ensure_seeded();
    products_no_reviews = [];
    for p in [root() -->][?:Product] {
        if not p.active {
            continue;
        }
        reviews = [r for r in [p -->][?:Review]];
        if len(reviews) == 0 {
            products_no_reviews.append(product_dict(p));
        }
    }
    return products_no_reviews;
}

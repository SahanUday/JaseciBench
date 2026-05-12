"""Catalog service: categories, products, variants, search."""

import from models { Category, Product, Variant, Review }
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
    if review_count > 0 {
        rating_sum: float = float(sum([r.rating for r in reviews]));
        avg: float = rating_sum / float(review_count);
        average_rating = int(avg * 100) / 100.0;
    } else {
        average_rating = 0.0;
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
        };
    }
    variants = [variant_dict(v) for v in [p -->][?:Variant]];
    min_price = min([v.price for v in [p -->][?:Variant]]) if variants else 0.0;
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
    q_lower = q.lower() if q else "";
    matches = [];
    for p in [root() -->][?:Product] {
        if not p.active {
            continue;
        }
        # Text search filter
        if q and not (q_lower in p.name.lower() or q_lower in p.description.lower()) {
            continue;
        }
        # Category filter
        if category_id and p.category_id != category_id {
            continue;
        }
        # Price filter
        variants = [p -->][?:Variant];
        if variants {
            min_variant_price = min([v.price for v in variants]);
            if min_price > 0.0 and min_variant_price < min_price {
                continue;
            }
            if max_price > 0.0 and min_variant_price > max_price {
                continue;
            }
        }
        matches.append(product_dict(p));
    }
    return matches;
}

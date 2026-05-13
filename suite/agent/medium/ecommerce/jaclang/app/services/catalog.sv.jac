"""Catalog service: categories, products, variants, search."""

import from models { Category, Product, Variant, Review }
import from seed { seed_catalog }

# Re-export helpers for other services


def ensure_seeded() -> None {
    if not [root -->][?:Category] {
        seed_catalog();
    }
}


def category_dict(c: Category) -> dict {
    return {
        "id": c.id,
        "name": c.name,
        "description": c.description,
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
    average_rating = 0.0;
    if review_count > 0 {
        average_rating = (sum([r.rating for r in reviews]) / review_count);
    }

    variants_nodes = [p -->][?:Variant];
    total_stock = 0;
    if variants_nodes {
        total_stock = sum([v.stock_qty for v in variants_nodes]);
    }

    if not include_variants {
        return {
            "id": p.id,
            "name": p.name,
            "description": p.description,
            "category_id": p.category_id,
            "active": p.active,
            "total_stock": total_stock,
            "review_count": review_count,
            "average_rating": average_rating,
        };
    }
    variants = [variant_dict(v) for v in variants_nodes];
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
        "total_stock": total_stock,
        "variants": variants,
        "min_price": min_price,
        "review_count": review_count,
        "average_rating": average_rating,
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
        products = [p for p in products if p.category_id == category_id];
    }
    return [product_dict(p) for p in products if p.active];
}


def:pub top_rated_products(limit: int = 10) -> list[dict] {
    ensure_seeded();

    products = [p for p in [root() -->][?:Product] if p.active];

    def avg_rating(p: Product) -> float {
        reviews = [p -->][?:Review];
        if not reviews {
            return 0.0;
        }
        return (sum([r.rating for r in reviews]) / len(reviews));
    }

    sorted_products = sorted(products, key=avg_rating, reverse=True);
    if limit <= 0 {
        return [];
    }
    return [product_dict(p) for p in sorted_products][:limit];
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


def:pub search_products(
    q: str = "",
    category_id: str = "",
    min_price: float = 0.0,
    max_price: float = 0.0
) -> list[dict] {
    ensure_seeded();

    q_lower = q.lower();
    matches = [];

    for p in [root() -->][?:Product] {
        if not p.active {
            continue;
        }

        if category_id and p.category_id != category_id {
            continue;
        }

        if q_lower {
            if (q_lower not in p.name.lower()) and (q_lower not in p.description.lower()) {
                continue;
            }
        }

        variants = [p -->][?:Variant];
        p_min_price = 0.0;
        if variants {
            p_min_price = min([v.price for v in variants]);
        }

        if min_price > 0.0 and p_min_price < min_price {
            continue;
        }
        if max_price > 0.0 and p_min_price > max_price {
            continue;
        }

        matches.append(product_dict(p));
    }

    return matches;
}


def:pub update_variant_price(variant_id: str, new_price: float) -> dict {
    ensure_seeded();

    if new_price < 0.0 {
        return {"error": "new_price must be non-negative", "status": 400};
    }

    v = find_variant(variant_id);
    if v is None {
        return {"error": "Variant not found", "status": 404};
    }

    v.price = new_price;
    return variant_dict(v);
}


def:pub deactivate_product(product_id: str) -> dict {
    ensure_seeded();

    p = find_product(product_id);
    if p is None {
        return {"error": "Product not found", "status": 404};
    }

    p.active = False;
    return product_dict(p);
}


# Average product price
# Mean of every variant's price across all active products.
# Returns 0.0 when there are no active variants.
def:pub average_product_price() -> float {
    ensure_seeded();

    prices = [];
    for p in [root() -->][?:Product] {
        if not p.active {
            continue;
        }
        for v in [p -->][?:Variant] {
            prices.append(v.price);
        }
    }

    if not prices {
        return 0.0;
    }
    return (sum(prices) / len(prices));
}


# Products without reviews
# Active products that have zero Reviews.
def:pub products_without_reviews() -> list[dict] {
    ensure_seeded();

    products = [];
    for p in [root() -->][?:Product] {
        if not p.active {
            continue;
        }
        reviews = [p -->][?:Review];
        if not reviews {
            products.append(product_dict(p));
        }
    }
    return products;
}


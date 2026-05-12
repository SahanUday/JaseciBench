"""Catalog service: categories, products, variants, search."""

import from models { Category, Product, Variant, Review, OrderItem }
import from seed { seed_catalog }


def ensure_seeded() -> None {
    if not [root() -->][?:Category] {
        seed_catalog();
    }
}


def category_dict(c: Category) -> dict {
    product_count = len([p for p in [root() -->][?:Product] if p.active and p.category_id == c.id]);
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
    
    # Calculate total stock across all variants
    variant_nodes = [p -->][?:Variant];
    total_stock = sum([v.stock_qty for v in variant_nodes]) if variant_nodes else 0;
    
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


def:pub product_count() -> int {
    ensure_seeded();
    return len([p for p in [root() -->][?:Product] if p.active]);
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
        if q_lower {
            if not (q_lower in p.name.lower() or q_lower in p.description.lower()) {
                continue;
            }
        }
        
        # Category filter
        if category_id {
            if p.category_id != category_id {
                continue;
            }
        }
        
        # Price filters - calculate min price from variants
        variants = [p -->][?:Variant];
        if variants {
            product_min_price = min([v.price for v in variants]);
            
            if min_price > 0.0 {
                if product_min_price < min_price {
                    continue;
                }
            }
            
            if max_price > 0.0 {
                if product_min_price > max_price {
                    continue;
                }
            }
        }
        
        matches.append(product_dict(p));
    }
    return matches;
}


def:pub top_rated_products(limit: int) -> list[dict] {
    ensure_seeded();
    products = [root() -->][?:Product];
    
    # Get product dicts for all active products
    product_dicts = [product_dict(p) for p in products if p.active];
    
    # Sort by average_rating descending
    product_dicts.sort(key=lambda x: x["average_rating"], reverse=True);
    
    # Return first limit entries
    return product_dicts[:limit];
}


def:pub list_out_of_stock_products() -> list[dict] {
    ensure_seeded();
    out_of_stock = [];
    
    for p in [root() -->][?:Product] {
        if not p.active {
            continue;
        }
        
        # Get all variants for this product
        variants = [p -->][?:Variant];
        
        # Skip products with no variants
        if not variants {
            continue;
        }
        
        # Check if ALL variants have stock_qty == 0
        all_out_of_stock = all([v.stock_qty == 0 for v in variants]);
        
        if all_out_of_stock {
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
        
        # Get all variants for this product
        variants = [p -->][?:Variant];
        
        # Skip products with no variants
        if not variants {
            continue;
        }
        
        # Check if ANY variant has stock_qty < threshold
        has_low_stock = any([v.stock_qty < threshold for v in variants]);
        
        if has_low_stock {
            low_stock.append(product_dict(p));
        }
    }
    
    return low_stock;
}


def:pub update_variant_price(variant_id: str, new_price: float) -> dict {
    ensure_seeded();
    
    # Validate price is non-negative
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
    
    # Return updated variant dict
    return variant_dict(v);
}


def:pub deactivate_product(product_id: str) -> dict {
    ensure_seeded();
    
    # Find the product
    p = find_product(product_id);
    if p is None {
        return {"error": "Product not found", "status": 404};
    }
    
    # Set active to False
    p.active = False;
    
    # Return updated product dict
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
        
        # Search only in product name
        if q_lower in p.name.lower() {
            matches.append(product_dict(p));
        }
    }
    
    return matches;
}


def:pub most_purchased_products(limit: int) -> list[dict] {
    ensure_seeded();
    
    # Get all order items (excluding returned items)
    all_order_items = [root() -->][?:OrderItem];
    
    # Build dict: variant_id -> total_quantity
    variant_quantities = {};
    for item in all_order_items {
        if item.returned {
            continue;
        }
        if item.variant_id in variant_quantities {
            variant_quantities[item.variant_id] += item.quantity;
        } else {
            variant_quantities[item.variant_id] = item.quantity;
        }
    }
    
    # Build dict: product_id -> total_units_sold
    product_units = {};
    for (variant_id, qty) in variant_quantities.items() {
        # Find the product for this variant
        for p in [root() -->][?:Product] {
            for v in [p -->][?:Variant] {
                if v.id == variant_id {
                    if p.id in product_units {
                        product_units[p.id] += qty;
                    } else {
                        product_units[p.id] = qty;
                    }
                    break;
                }
            }
        }
    }
    
    # Build list of product dicts with units_sold
    results = [];
    for p in [root() -->][?:Product] {
        if p.id in product_units {
            pd = product_dict(p, include_variants=False);
            pd["units_sold"] = product_units[p.id];
            results.append(pd);
        }
    }
    
    # Sort by units_sold descending
    results.sort(key=lambda x: x["units_sold"], reverse=True);
    
    # Return top N
    return results[:limit];
}


def:pub average_product_price() -> float {
    ensure_seeded();
    
    # Collect all variant prices from all active products
    all_prices = [];
    for p in [root() -->][?:Product] {
        if p.active {
            variants = [p -->][?:Variant];
            for v in variants {
                all_prices.append(v.price);
            }
        }
    }
    
    # Return mean price, or 0.0 if no variants exist
    if len(all_prices) == 0 {
        return 0.0;
    }
    return sum(all_prices) / len(all_prices);
}


def:pub products_without_reviews() -> list[dict] {
    ensure_seeded();
    products_no_reviews = [];
    
    for p in [root() -->][?:Product] {
        if not p.active {
            continue;
        }
        
        # Check if product has any reviews
        reviews = [p -->][?:Review];
        if len(reviews) == 0 {
            products_no_reviews.append(product_dict(p));
        }
    }
    
    return products_no_reviews;
}

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
    
    # Calculate total stock across all variants
    all_variants = [p -->][?:Variant];
    total_stock = sum([v.stock_qty for v in all_variants]) if all_variants else 0;
    
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
    variants = [variant_dict(v) for v in all_variants];
    min_price = min([v.price for v in all_variants]) if all_variants else 0.0;
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


def:pub search_by_name(q: str) -> list[dict] {
    ensure_seeded();
    
    q_lower = q.lower();
    matches = [];
    
    for p in [root() -->][?:Product] {
        if not p.active {
            continue;
        }
        
        # Match against name or description
        if q_lower in p.name.lower() or q_lower in p.description.lower() {
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
        if q_lower and not (q_lower in p.name.lower() or q_lower in p.description.lower()) {
            continue;
        }
        
        # Category filter
        if category_id and p.category_id != category_id {
            continue;
        }
        
        # Price filter (check min variant price)
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
    
    # Get all active products
    products = [root() -->][?:Product];
    active_products = [p for p in products if p.active];
    
    # Convert to dicts
    product_dicts = [product_dict(p) for p in active_products];
    
    # Sort by average_rating descending
    sorted_products = sorted(product_dicts, key=lambda p: p["average_rating"], reverse=True);
    
    # Return limited results
    return sorted_products[:limit];
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
    
    # Return updated variant
    return variant_dict(v);
}


def:pub list_out_of_stock_products() -> list[dict] {
    ensure_seeded();
    
    # Get all active products
    products = [root() -->][?:Product];
    out_of_stock = [];
    
    for p in products {
        if not p.active {
            continue;
        }
        
        # Check if all variants have stock_qty == 0
        variants = [p -->][?:Variant];
        if not variants {
            # Product with no variants is considered out of stock
            out_of_stock.append(product_dict(p));
            continue;
        }
        
        # Check if total stock is 0 (all variants out of stock)
        total_stock = sum([v.stock_qty for v in variants]);
        if total_stock == 0 {
            out_of_stock.append(product_dict(p));
        }
    }
    
    return out_of_stock;
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


def:pub low_stock_products(threshold: int) -> list[dict] {
    ensure_seeded();
    
    # Get all active products
    products = [root() -->][?:Product];
    low_stock = [];
    
    for p in products {
        if not p.active {
            continue;
        }
        
        # Check if any variant has stock_qty < threshold
        variants = [p -->][?:Variant];
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


def:pub most_purchased_products(limit: int) -> list[dict] {
    ensure_seeded();
    
    # Get all OrderItems
    order_items = [root() -->][?:OrderItem];
    
    # Build a map: product_id -> total_units_sold
    product_sales: dict[str, int] = {};
    product_map: dict[str, Product] = {};
    
    for oi in order_items {
        # Skip returned items
        if oi.returned {
            continue;
        }
        
        # Find the variant to get the product
        variant = find_variant(oi.variant_id);
        if variant is None {
            continue;
        }
        
        # Find the product that owns this variant
        product_id = "";
        for p in [root() -->][?:Product] {
            for v in [p -->][?:Variant] {
                if v.id == oi.variant_id {
                    product_id = p.id;
                    product_map[product_id] = p;
                    break;
                }
            }
            if product_id {
                break;
            }
        }
        
        if not product_id {
            continue;
        }
        
        # Accumulate quantity
        if product_id in product_sales {
            product_sales[product_id] += oi.quantity;
        } else {
            product_sales[product_id] = oi.quantity;
        }
    }
    
    # Build result list with product info + units_sold
    results = [];
    for (product_id, units_sold) in product_sales.items() {
        p = product_map[product_id];
        pd = product_dict(p);
        pd["units_sold"] = units_sold;
        results.append(pd);
    }
    
    # Sort by units_sold descending
    sorted_results = sorted(results, key=lambda x: x["units_sold"], reverse=True);
    
    # Return top N
    return sorted_results[:limit];
}


def:pub product_count() -> int {
    ensure_seeded();
    
    # Count all active products
    products = [root() -->][?:Product];
    return len([p for p in products if p.active]);
}


def:pub average_product_price() -> float {
    ensure_seeded();
    
    # Get all active products
    products = [root() -->][?:Product];
    active_products = [p for p in products if p.active];
    
    # Collect all variant prices
    all_prices = [];
    for p in active_products {
        variants = [p -->][?:Variant];
        for v in variants {
            all_prices.append(v.price);
        }
    }
    
    # Return average or 0.0 if no variants
    if len(all_prices) == 0 {
        return 0.0;
    }
    
    return sum(all_prices) / len(all_prices);
}


def:pub products_without_reviews() -> list[dict] {
    ensure_seeded();
    
    # Get all active products
    products = [root() -->][?:Product];
    products_no_reviews = [];
    
    for p in products {
        if not p.active {
            continue;
        }
        
        # Check if product has zero reviews
        reviews = [p -->][?:Review];
        if len(reviews) == 0 {
            products_no_reviews.append(product_dict(p));
        }
    }
    
    return products_no_reviews;
}

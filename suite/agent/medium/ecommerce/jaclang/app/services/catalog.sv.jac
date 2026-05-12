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
    average_rating = 0.0;
    if review_count > 0 {
        total_rating = sum([r.rating for r in reviews]);
        average_rating = round(total_rating / review_count, 2);
    }
    
    # Calculate total stock across all variants
    variants_list = [p -->][?:Variant];
    total_stock = sum([v.stock_qty for v in variants_list]);
    
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
    variants = [variant_dict(v) for v in variants_list];
    min_price = min([v.price for v in variants_list]) if len(variants_list) > 0 else 0.0;
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


def:pub product_count() -> int {
    ensure_seeded();
    return len([p for p in [root() -->][?:Product] if p.active]);
}


def:pub average_product_price() -> float {
    ensure_seeded();
    all_prices = [];
    for p in [root() -->][?:Product] {
        if p.active {
            for v in [p -->][?:Variant] {
                all_prices.append(v.price);
            }
        }
    }
    if len(all_prices) == 0 {
        return 0.0;
    }
    return sum(all_prices) / len(all_prices);
}


def:pub list_categories() -> list[dict] {
    ensure_seeded();
    return [category_dict(c) for c in [root() -->][?:Category]];
}


def:pub list_products(category_id: str = "") -> list[dict] {
    ensure_seeded();
    products = [root() -->][?:Product];
    if category_id != "" {
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
            if q_lower not in p.name.lower() and q_lower not in p.description.lower() {
                continue;
            }
        }
        
        # Category filter
        if category_id and p.category_id != category_id {
            continue;
        }
        
        # Price filters - calculate min variant price
        variants = [p -->][?:Variant];
        if len(variants) == 0 {
            continue;
        }
        product_min_price = min([v.price for v in variants]);
        
        if min_price > 0.0 and product_min_price < min_price {
            continue;
        }
        
        if max_price > 0.0 and product_min_price > max_price {
            continue;
        }
        
        matches.append(product_dict(p));
    }
    
    return matches;
}


def:pub search_by_name(q: str) -> list[dict] {
    ensure_seeded();
    q_lower = q.lower();
    matches = [];
    
    for p in [root() -->][?:Product] {
        if not p.active {
            continue;
        }
        
        # Name-only search filter
        if q_lower in p.name.lower() {
            matches.append(product_dict(p));
        }
    }
    
    return matches;
}


def:pub top_rated_products(limit: int) -> list[dict] {
    ensure_seeded();
    products = [root() -->][?:Product];
    active_products = [p for p in products if p.active];
    
    # Convert to dicts with ratings
    product_dicts = [product_dict(p) for p in active_products];
    
    # Sort by average_rating descending
    sorted_products = sorted(product_dicts, key=lambda p: p["average_rating"], reverse=True);
    
    # Return limited results
    return sorted_products[:limit];
}


def:pub update_variant_price(variant_id: str, new_price: float) -> dict {
    ensure_seeded();
    
    # Find the variant
    v = find_variant(variant_id);
    if v is None {
        return {"error": "Variant not found", "status": 404};
    }
    
    # Validate price (negative not allowed, zero is fine)
    if new_price < 0.0 {
        return {"error": "Price cannot be negative", "status": 400};
    }
    
    # Update the price
    v.price = new_price;
    
    # Return updated variant dict
    return variant_dict(v);
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
        if len(variants) == 0 {
            continue;
        }
        
        # Check if ALL variants have stock_qty == 0
        all_out_of_stock = True;
        for v in variants {
            if v.stock_qty > 0 {
                all_out_of_stock = False;
                break;
            }
        }
        
        # If all variants are out of stock, add to results
        if all_out_of_stock {
            out_of_stock.append(product_dict(p));
        }
    }
    
    return out_of_stock;
}


def:pub deactivate_product(product_id: str) -> dict | None {
    ensure_seeded();
    
    # Find the product
    p = find_product(product_id);
    if p is None {
        return None;
    }
    
    # Set active to False
    p.active = False;
    
    # Return the updated product dict
    return product_dict(p);
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
        if len(variants) == 0 {
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
        
        # If any variant is low stock, add to results
        if has_low_stock {
            low_stock.append(product_dict(p));
        }
    }
    
    return low_stock;
}


def:pub most_purchased_products(limit: int) -> list[dict] {
    ensure_seeded();
    
    # Get all order items
    order_items = [root() -->][?:OrderItem];
    
    # Build a map of product_id -> total_units_sold
    product_sales: dict[str, int] = {};
    
    for oi in order_items {
        # Skip returned items
        if oi.returned {
            continue;
        }
        
        # Find the variant to get the product
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
            if product_id != "" {
                break;
            }
        }
        
        if product_id == "" {
            continue;
        }
        
        # Add to sales count
        if product_id in product_sales {
            product_sales[product_id] = product_sales[product_id] + oi.quantity;
        } else {
            product_sales[product_id] = oi.quantity;
        }
    }
    
    # Build result list with product details and sort
    result_with_sales = [];
    for pid in product_sales {
        p = find_product(pid);
        if p is not None and p.active {
            pdict = product_dict(p);
            pdict["units_sold"] = product_sales[pid];
            result_with_sales.append(pdict);
        }
    }
    
    # Sort by units_sold descending (manual bubble sort to avoid type checker issues)
    n = len(result_with_sales);
    for i in range(n) {
        for j in range(0, n - i - 1) {
            if result_with_sales[j]["units_sold"] < result_with_sales[j + 1]["units_sold"] {
                temp = result_with_sales[j];
                result_with_sales[j] = result_with_sales[j + 1];
                result_with_sales[j + 1] = temp;
            }
        }
    }
    
    return result_with_sales[:limit];
}


def:pub products_without_reviews() -> list[dict] {
    ensure_seeded();
    no_reviews = [];
    
    for p in [root() -->][?:Product] {
        if not p.active {
            continue;
        }
        
        # Get all reviews for this product
        reviews = [p -->][?:Review];
        
        # If no reviews, add to results
        if len(reviews) == 0 {
            no_reviews.append(product_dict(p));
        }
    }
    
    return no_reviews;
}

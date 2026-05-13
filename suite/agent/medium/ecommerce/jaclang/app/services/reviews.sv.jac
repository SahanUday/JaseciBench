"""Reviews service: list reviews per product, add review."""

import from datetime { datetime }
import from models { Review, Product }
import from services.catalog { ensure_seeded, find_product }


def review_dict(r: Review) -> dict {
    return {
        "id": r.id,
        "product_id": r.product_id,
        "user_id": r.user_id,
        "rating": r.rating,
        "title": r.title,
        "body": r.body,
        "created_at": r.created_at,
    };
}


def:pub list_reviews(product_id: str) -> dict {
    ensure_seeded();
    p = find_product(product_id);
    if p is None {
        return {"error": "Product not found", "status": 404};
    }
    reviews = [review_dict(r) for r in [p -->][?:Review]];
    return {"reviews": reviews, "count": len(reviews)};
}


def:pub list_user_reviews(user_id: str) -> dict {
    ensure_seeded();

    reviews = [];
    for prod in [root -->][?:Product] {
        for r in [prod -->][?:Review] {
            if r.user_id == user_id {
                reviews.append(review_dict(r));
            }
        }
    }

    return {"reviews": reviews, "count": len(reviews)};
}


def:pub recent_reviews(limit: int = 10) -> dict {
    ensure_seeded();

    if limit < 0 {
        return {"error": "limit must be non-negative", "status": 400};
    }

    reviews = [];
    for prod in [root -->][?:Product] {
        for r in [prod -->][?:Review] {
            reviews.append(review_dict(r));
        }
    }

    # Sort newest-first by created_at (stored as string).
    # (Avoid higher-order sort overload issues by doing a simple selection pass.)
    sorted_reviews = [];
    for _i in range(len(reviews)) {
        best_idx = 0;
        for j in range(len(reviews)) {
            if reviews[j]["created_at"] > reviews[best_idx]["created_at"] {
                best_idx = j;
            }
        }
        sorted_reviews.append(reviews.pop(best_idx));
    }
    reviews = sorted_reviews;

    if limit == 0 {
        return {"reviews": [], "count": 0};
    }

    limited = reviews[:limit];
    return {"reviews": limited, "count": len(limited)};
}


def:pub add_review(product_id: str, user_id: str, rating: int, title: str = "", body: str = "") -> dict {
    ensure_seeded();
    p = find_product(product_id);
    if p is None {
        return {"error": "Product not found", "status": 404};
    }

    if rating < 1 or rating > 5 {
        return {"error": "Rating must be between 1 and 5", "status": 400};
    }

    next_num = len([root -->][?:Review]);
    for prod in [root -->][?:Product] {
        next_num = next_num + len([prod -->][?:Review]);
    }
    rid = "rev_" + str(next_num + 1).zfill(4);
    now_str = str(datetime.now());

    new_review = Review(
        id=rid,
        product_id=product_id,
        user_id=user_id,
        rating=rating,
        title=title,
        body=body,
        created_at=now_str,
    );
    p ++> new_review;
    return review_dict(new_review);
}


def:pub product_review_summary(product_id: str) -> dict {
    ensure_seeded();
    p = find_product(product_id);
    if p is None {
        return {"error": "Product not found", "status": 404};
    }
    reviews = [r for r in [p -->][?:Review]];
    if not reviews {
        return {"count": 0, "average_rating": 0.0};
    }
    avg = sum([r.rating for r in reviews]) / len(reviews);
    return {"count": len(reviews), "average_rating": int(avg * 100) / 100.0};
}

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


def:pub add_review(product_id: str, user_id: str, rating: int, title: str = "", body: str = "") -> dict {
    ensure_seeded();
    p = find_product(product_id);
    if p is None {
        return {"error": "Product not found", "status": 404};
    }
    if rating < 1 or rating > 5 {
        return {"error": "Rating must be between 1 and 5", "status": 400};
    }

    next_num = len([root() -->][?:Review]);
    for prod in [root() -->][?:Product] {
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


def:pub list_user_reviews(user_id: str) -> dict {
    ensure_seeded();
    all_reviews = [];
    for prod in [root() -->][?:Product] {
        for r in [prod -->][?:Review] {
            if r.user_id == user_id {
                all_reviews.append(review_dict(r));
            }
        }
    }
    return {"reviews": all_reviews, "count": len(all_reviews)};
}


def:pub recent_reviews(limit: int) -> dict {
    ensure_seeded();
    all_reviews = [];
    for prod in [root() -->][?:Product] {
        for r in [prod -->][?:Review] {
            all_reviews.append(review_dict(r));
        }
    }
    # Sort by created_at in descending order (newest first)
    for i in range(len(all_reviews) - 1) {
        for j in range(len(all_reviews) - 1 - i) {
            if all_reviews[j]["created_at"] < all_reviews[j + 1]["created_at"] {
                temp = all_reviews[j];
                all_reviews[j] = all_reviews[j + 1];
                all_reviews[j + 1] = temp;
            }
        }
    }
    limited_reviews = all_reviews[:limit];
    return {"reviews": limited_reviews, "count": len(limited_reviews)};
}

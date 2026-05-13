"""Test the list_user_reviews endpoint."""

import from services.reviews { list_user_reviews }

test "list_user_reviews returns review for user_001" {
    result = list_user_reviews("user_001");
    assert result["count"] == 1;
    assert len(result["reviews"]) == 1;
    review = result["reviews"][0];
    assert review["id"] == "rev_001";
    assert review["user_id"] == "user_001";
    assert review["product_id"] == "prod_001";
    assert review["rating"] == 5;
    assert review["title"] == "Great fit";
}

test "list_user_reviews returns review for user_002" {
    result = list_user_reviews("user_002");
    assert result["count"] == 1;
    assert len(result["reviews"]) == 1;
    review = result["reviews"][0];
    assert review["id"] == "rev_002";
    assert review["user_id"] == "user_002";
}

test "list_user_reviews returns review for user_003" {
    result = list_user_reviews("user_003");
    assert result["count"] == 1;
    assert len(result["reviews"]) == 1;
    review = result["reviews"][0];
    assert review["id"] == "rev_003";
    assert review["user_id"] == "user_003";
    assert review["product_id"] == "prod_005";
}

test "list_user_reviews returns empty list for user with no reviews" {
    result = list_user_reviews("user_999");
    assert result["count"] == 0;
    assert len(result["reviews"]) == 0;
}

test "list_user_reviews returns all required fields" {
    result = list_user_reviews("user_001");
    review = result["reviews"][0];
    assert "id" in review;
    assert "product_id" in review;
    assert "user_id" in review;
    assert "rating" in review;
    assert "title" in review;
    assert "body" in review;
    assert "created_at" in review;
}

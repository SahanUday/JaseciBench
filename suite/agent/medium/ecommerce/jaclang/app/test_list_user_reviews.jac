"""Test the new list_user_reviews endpoint."""

import from services.reviews { list_user_reviews }


test "list_user_reviews returns reviews for alice" {
    result = list_user_reviews("user_001");
    assert result["count"] == 1;
    assert len(result["reviews"]) == 1;
    assert result["reviews"][0]["user_id"] == "user_001";
    assert result["reviews"][0]["product_id"] == "prod_001";
    assert result["reviews"][0]["rating"] == 5;
    assert result["reviews"][0]["title"] == "Great fit";
}


test "list_user_reviews returns reviews for bob" {
    result = list_user_reviews("user_002");
    assert result["count"] == 1;
    assert len(result["reviews"]) == 1;
    assert result["reviews"][0]["user_id"] == "user_002";
    assert result["reviews"][0]["product_id"] == "prod_001";
    assert result["reviews"][0]["rating"] == 4;
}


test "list_user_reviews returns reviews for carol" {
    result = list_user_reviews("user_003");
    assert result["count"] == 1;
    assert len(result["reviews"]) == 1;
    assert result["reviews"][0]["user_id"] == "user_003";
    assert result["reviews"][0]["product_id"] == "prod_005";
    assert result["reviews"][0]["rating"] == 5;
}


test "list_user_reviews returns empty for user with no reviews" {
    result = list_user_reviews("user_999");
    assert result["count"] == 0;
    assert len(result["reviews"]) == 0;
}

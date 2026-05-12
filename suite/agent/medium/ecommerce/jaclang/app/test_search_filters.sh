#!/bin/bash
# Test script for multi-criteria product search

BASE_URL="http://localhost:8001"

echo "=========================================="
echo "Multi-Criteria Product Search Tests"
echo "=========================================="
echo ""

echo "Test 1: Category filter (cat_004 - Tech) + min_price 80"
echo "Expected: Keyboard, Headphones"
curl -s -X POST "$BASE_URL/function/search_products" \
    -H "Content-Type: application/json" \
    -d '{"q":"","category_id":"cat_004","min_price":80.0,"max_price":0.0}' \
    | jq -r '.data.result[] | "  - " + .name + " ($" + (.min_price|tostring) + ")"'
echo ""

echo "Test 2: Text search 'coffee'"
echo "Expected: Coffee Maker"
curl -s -X POST "$BASE_URL/function/search_products" \
    -H "Content-Type: application/json" \
    -d '{"q":"coffee","category_id":"","min_price":0.0,"max_price":0.0}' \
    | jq -r '.data.result[] | "  - " + .name'
echo ""

echo "Test 3: Price range 20-100"
echo "Expected: Products with min_price between $20-$100"
curl -s -X POST "$BASE_URL/function/search_products" \
    -H "Content-Type: application/json" \
    -d '{"q":"","category_id":"","min_price":20.0,"max_price":100.0}' \
    | jq -r '.data.result[] | "  - " + .name + " ($" + (.min_price|tostring) + ")"'
echo ""

echo "Test 4: All filters empty (returns all active products)"
echo "Expected: All 8 active products"
COUNT=$(curl -s -X POST "$BASE_URL/function/search_products" \
    -H "Content-Type: application/json" \
    -d '{"q":"","category_id":"","min_price":0.0,"max_price":0.0}' \
    | jq -r '.data.result | length')
echo "  - Total products returned: $COUNT"
echo ""

echo "Test 5: Combined filters (text + category + price)"
echo "Expected: Keyboard only"
curl -s -X POST "$BASE_URL/function/search_products" \
    -H "Content-Type: application/json" \
    -d '{"q":"keyboard","category_id":"cat_004","min_price":80.0,"max_price":100.0}' \
    | jq -r '.data.result[] | "  - " + .name + " ($" + (.min_price|tostring) + ")"'
echo ""

echo "Test 6: No results (impossible criteria)"
echo "Expected: Empty array"
COUNT=$(curl -s -X POST "$BASE_URL/function/search_products" \
    -H "Content-Type: application/json" \
    -d '{"q":"nonexistent","category_id":"","min_price":0.0,"max_price":0.0}' \
    | jq -r '.data.result | length')
echo "  - Products found: $COUNT"
echo ""

echo "=========================================="
echo "All tests completed!"
echo "=========================================="

# Multi-Criteria Product Search Implementation

## Summary

Successfully implemented multi-criteria search functionality allowing customers to filter products by:
- Text query (name/description)
- Category
- Price range (min/max)

## Changes Made

### 1. Server-Side (`services/catalog.sv.jac`)

Updated `search_products` function to accept four parameters:

```jac
def:pub search_products(
    q: str = "",
    category_id: str = "",
    min_price: float = 0.0,
    max_price: float = 0.0
) -> list[dict]
```

**Filter Logic:**
- All parameters default to empty/zero (no filter)
- Returns results when ANY filter is set (not just text query)
- Text filter: matches against product name and description (case-insensitive)
- Category filter: exact match on category_id
- Price filter: uses minimum variant price per product
  - min_price: filters products where min_variant_price >= min_price
  - max_price: filters products where min_variant_price <= max_price
- All filters are applied cumulatively (AND logic)

### 2. Client-Side (`pages/SearchPage.cl.jac`)

**New Features:**
- Fetches categories on mount via `list_categories()`
- Category dropdown with "All Categories" default option
- Min/Max price text inputs (converted to float on submit)
- Updated form layout with two rows:
  - Row 1: Search input + Category dropdown
  - Row 2: Min Price + Max Price + Search button
- Updated empty state message to "No products match your search criteria."

**State Management:**
```jac
has query: str = "";
has category_id: str = "";
has min_price: str = "";
has max_price: str = "";
has categories: list = [];
```

## Verification

All test cases pass:

✅ Category + min_price filter (cat_004, $80+) → Keyboard, Headphones
✅ Text search only (q='shirt') → T-Shirt
✅ Max price filter ($30 max) → T-Shirt, Water Bottle
✅ Empty filters → All active products (8 items)
✅ Category dropdown populated → 6 categories
✅ Combined filters (text + category) → Keyboard

## API Example

```bash
curl -X POST http://localhost:8001/function/search_products \
  -H "Content-Type: application/json" \
  -d '{
    "q": "",
    "category_id": "cat_004",
    "min_price": 80.0,
    "max_price": 0.0
  }'
```

## UI Layout

```
┌─────────────────────────────────────────────────────────────┐
│ Search Products                                             │
├─────────────────────────────────────────────────────────────┤
│ [Search text input...        ] [Category Dropdown ▼]        │
│ [Min Price] [Max Price] [Search Button]                     │
└─────────────────────────────────────────────────────────────┘
```

## Notes

- Zero/empty values mean "no filter on that dimension"
- Price inputs accept any numeric text (converted to float)
- Category dropdown shows all categories from seed data
- Search works with any combination of filters
- All filters use AND logic (must match all specified criteria)

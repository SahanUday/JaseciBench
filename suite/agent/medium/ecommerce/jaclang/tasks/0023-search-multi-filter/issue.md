# Multi-criteria product search

The search endpoint only supports a single text `q`. Customers cannot
narrow by category or price. Add `category_id`, `min_price`, and
`max_price` parameters to `search_products`, and surface a category
dropdown plus min/max price inputs on the `/search` page.

## Bug location

Two changes:

1. `app/services/catalog.sv.jac`, the `search_products` function. It
   accepts only `q` and returns `[]` for empty `q`.
2. `app/pages/SearchPage.cl.jac`. It only has a text input and a
   submit button.

## Expected behaviour

### Server (`search_products`)

Accept four parameters (all default to empty/zero):

- `q: str = ""` (text matched against name and description)
- `category_id: str = ""` (filter by exact category id)
- `min_price: float = 0.0` (filter products whose min variant price >= min_price)
- `max_price: float = 0.0` (filter products whose min variant price <= max_price)

A zero/empty value means "no filter on that dimension". When ALL filters
are empty, the function should still return results (use any combination
of filters that the caller supplies).

### Client (`SearchPage`)

- Fetch `list_categories` on mount and render them in a `<select>`
  dropdown alongside the search bar.
- Add two `<input>` fields for min and max price (text inputs that the
  client converts to floats).
- The form submit calls `search_products(query, category_id, min_p, max_p)`.

## How to verify

```bash
# Tech category, min price $80
curl -s -X POST http://localhost:9000/function/search_products \
    -H "Content-Type: application/json" \
    -d '{"q":"","category_id":"cat_004","min_price":80.0,"max_price":0.0}' \
    | jq '.data.result[].name'
# expected: ["Keyboard", "Headphones"]
```

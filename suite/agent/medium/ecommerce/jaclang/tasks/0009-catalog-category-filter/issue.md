# Add category filter to the catalog page

The catalog page currently lists every active product with no way to
narrow by category. Add a category filter on both the server (so the
endpoint actually applies the filter) and the client (so the user can
click a category to filter the grid).

## Bug location

Two changes are required:

1. `app/services/catalog.sv.jac`, the `list_products` function. The
   `category_id` parameter is accepted but the filter logic is gone.
2. `app/pages/CatalogPage.cl.jac`. The `select_category` handler and
   the row of category buttons (including the "All" button) were
   removed; the page renders only the product grid.

## Expected behaviour

### Server (`list_products`)

When `category_id` is non-empty, return only products whose
`category_id` matches. When empty, return all active products as today.

### Client (`CatalogPage`)

- Add a `select_category(cat_id: str)` async handler that sets the
  `selected_cat` state and re-fetches `list_products(cat_id)`.
- Render an "All" button (clears the filter) plus one button per
  category from `categories`. The currently selected button gets a
  visually distinct style.

## How to verify

```bash
cd suite/agent/medium/ecommerce/jaclang/app
jac check main.jac
jac test tests/baseline.jac
```

Backend smoke (only Technology products):

```bash
curl -s -X POST http://localhost:9000/function/list_products \
    -H "Content-Type: application/json" -d '{"category_id":"cat_004"}' \
    | jq '.data.result | length'
# expected: 2 (Keyboard, Headphones)
```

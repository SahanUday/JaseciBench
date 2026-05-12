# Show product min price on the catalog cards

The catalog grid shows each product's name, description and variant
count, but no price. Customers have to click into a product to learn
what it costs. Surface the cheapest variant's price as a `min_price`
field on every product returned by the catalog, and render it on the
`<ProductCard>` component.

## Bug location

Two changes are required:

1. `app/services/catalog.sv.jac`, the `product_dict` helper. The
   `min_price` field is missing from the returned dict (it is computed
   nowhere).
2. `app/components/ProductCard.cl.jac`. The price `<span>` was removed;
   the card currently shows only the variant count.

## Expected behaviour

### Server (`product_dict`)

Add a `"min_price"` key whose value is `min(price)` across the
product's variants, or `0.0` if the product has no variants. Keep all
existing keys (`id`, `name`, `description`, `category_id`, `active`,
`variants`).

### Client (`ProductCard`)

Read `product["min_price"]` and render it as `"$" + str(min_price)`
inside a bold `<span>`. The card layout should keep the existing
"N variants" hint to the right.

## How to verify

```bash
cd suite/agent/medium/ecommerce/jaclang/app
jac check main.jac
jac test tests/baseline.jac
jac start main.jac --port 9000
```

Open <http://localhost:9000/> and confirm every catalog card displays
both the price and the variant count.

A backend smoke test:

```bash
curl -s -X POST http://localhost:9000/function/list_products \
    -H "Content-Type: application/json" -d '{}' | jq '.data.result[0].min_price'
# expected: 19.99
```

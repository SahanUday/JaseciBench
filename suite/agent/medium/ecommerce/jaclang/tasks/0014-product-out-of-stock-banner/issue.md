# Show "Currently unavailable" banner when all variants are out of stock

The product detail page at `/products/:id` lets the user select a variant
and click "Add to Cart" even when every variant has `stock_qty == 0`.
The button does become disabled, but there is no visual cue at the top of
the page telling the customer the product is unavailable. Add a banner
that surfaces the out-of-stock state.

## Bug location

`app/pages/ProductPage.cl.jac`. After the product name and description
block, an out-of-stock banner is missing.

## Expected behaviour

When the **sum** of `stock_qty` across all variants is zero, render a
visible banner element somewhere between the product description and
the variant list. The banner must:

- Contain the literal phrase `Currently unavailable`.
- Use a destructive/warning color palette (a `bg-red-` background or
  `text-red-` foreground class is fine).
- Not render at all when at least one variant has stock.

## How to verify

```bash
cd suite/agent/medium/ecommerce/jaclang/app
jac check main.jac
jac start main.jac --port 9000
```

Open <http://localhost:9000/products/prod_001> (T-Shirt has stock).
Then visit a product whose variants you have set to 0 stock.

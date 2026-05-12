# Add a dedicated order detail page

The orders list at `/orders` shows a row per order with id, address,
status and an inline Cancel button, but there is no way to drill into
one order and see its line items and payments. Add a dedicated detail
page at `/orders/:id`, a route registration, and a navigable link from
the order list.

## Bug location

Three changes:

1. `app/pages/OrderDetailPage.cl.jac` does not exist; create it.
2. `app/frontend.cl.jac` does not register a `/orders/:id` route; wire
   it under `<Routes>`.
3. `app/pages/OrdersPage.cl.jac` shows the order id as plain text;
   make it a `<Link to={"/orders/" + o["id"]}>` so users can navigate.

## Expected behaviour

### `OrderDetailPage`

A `def:pub OrderDetailPage() -> JsxElement` that:

- Reads the order id with `useParams()["id"]`.
- Calls `get_order(oid)` from `../services/orders` and stores the
  result in a `has order: Any = None` field.
- Renders the order id, status, shipping address, every line item with
  its subtotal, and a grand total.
- Shows a Cancel button when `order["status"] == "pending"` that calls
  `cancel_order(oid)` and refreshes the page.
- Includes a back link `<Link to="/orders">` (an arrow + label is fine).

### `frontend.cl.jac`

Add the route `<Route path="/orders/:id" element={<OrderDetailPage />} />`
inside the existing `<Routes>` block, after the `/orders` route.

### `OrdersPage.cl.jac`

Wrap the order id text in a `<Link to={"/orders/" + o["id"]}>`.

## How to verify

```bash
cd suite/agent/medium/ecommerce/jaclang/app
jac check main.jac
jac start main.jac --port 9000
```

Open <http://localhost:9000/orders>, click an order id, see the
detail page.

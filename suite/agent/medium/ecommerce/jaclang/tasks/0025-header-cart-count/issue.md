# Show a cart count badge on the header Cart link

The header's `Cart` link is a static label. Customers cannot tell at a
glance whether they have items in the cart. Make `Header.cl.jac`
fetch the current user's cart on mount and render a count badge on
the Cart link when `count > 0`.

## Bug location

`app/components/Header.cl.jac`. The component is currently a pure
view: no `has` state, no async effect, no `sv import`. To show the
badge, you must turn it into a stateful component that imports and
calls `get_cart` on mount.

## Expected behaviour

### `Header`

- Add `sv import from ..services.cart { get_cart }`.
- Add `has cart_count: int = 0`.
- In `async can with entry`, call `await get_cart("user_001")` and
  store the `count` field in `cart_count`.
- Render a small badge `<span>` next to the existing `Cart` label
  when `cart_count > 0` (any pill-shaped Tailwind palette is fine).

### Server

The base `get_cart` already returns a `count` field; no server change
is required.

## How to verify

```bash
cd suite/agent/medium/ecommerce/jaclang/app
jac check main.jac
jac start main.jac --port 9000
```

Open <http://localhost:9000/> and confirm the Cart link in the header
shows a count badge (alice's seeded cart has 1 item).

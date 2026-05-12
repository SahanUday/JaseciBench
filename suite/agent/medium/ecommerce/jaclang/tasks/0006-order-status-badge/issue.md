# Add color-coded status badge to /orders page

The `/orders` page renders each order's status as plain gray text.
Statuses span six values (pending, processed, shipped, delivered,
cancelled, returned), and the user has to read the literal word every
time. Add a color-coded pill badge so each status is visually
distinguishable at a glance.

## Bug location

`app/pages/OrdersPage.cl.jac`. The `status_color` helper that maps a
status string to Tailwind color classes is missing, and the badge
itself is rendered with a plain `text-xs text-gray-600` className.

## Expected behaviour

- A `def status_color(status: str) -> str` helper at module scope that
  returns a Tailwind background+text color pair for each status.
- Suggested mapping (any equivalent palette is fine):
  - delivered:  green  (`bg-green-100 text-green-700`)
  - shipped:    blue   (`bg-blue-100 text-blue-700`)
  - processed:  yellow (`bg-yellow-100 text-yellow-700`)
  - pending:    gray   (`bg-gray-100 text-gray-700`)
  - cancelled:  red    (`bg-red-100 text-red-700`)
  - returned:   purple (`bg-purple-100 text-purple-700`)
- The status badge in the order list renders as a rounded pill with the
  appropriate background color (use `rounded-full`, padding like
  `px-2.5 py-1`, and the color classes returned by `status_color`).

## How to verify

```bash
cd suite/agent/medium/ecommerce/jaclang/app
jac check main.jac
jac start main.jac --port 9000
```

Open <http://localhost:9000/orders> and confirm each order's status
shows as a colored pill matching the table above.

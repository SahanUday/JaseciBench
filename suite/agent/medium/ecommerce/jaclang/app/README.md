# E-commerce app (Jac fullstack reference)

Reference implementation that benchmark agents edit when solving tasks
under `../tasks/`. Pairs with `../../python/` (FastAPI equivalent):
same domain, same seed data.

## Run

```bash
cd suite/agent/medium/ecommerce/jaclang/app
jac install                          # one-time npm + python deps
jac start main.jac --port 9000       # backend + frontend
```

- Frontend: <http://localhost:9000/>
- API docs: <http://localhost:9000/docs>
- Endpoint pattern: `POST /function/<name>` with JSON body matching the
  function signature (positional args become JSON keys).

The graph is auto-seeded on the first endpoint call (8 products,
3 users, 5 orders, 3 reviews).

## Layout

```
app/
├── main.jac                # registry: server imports + to cl: + def:pub app
├── jac.toml                # entry-point=main.jac, base_route_app=app
├── global.css              # @import "tailwindcss"
├── models.jac              # 11 node types (Category, Product, Variant,
│                           #   Review, CartItem, Order, OrderItem, Payment,
│                           #   Address, PaymentMethod, UserProfile)
├── seed.jac                # def:pub seed_catalog (idempotent)
├── frontend.cl.jac         # Shell with Router/Routes (5 routes)
├── services/               # def:pub endpoints, NOT walker:pub
│   ├── catalog.sv.jac      # 4 endpoints
│   ├── cart.sv.jac         # 6 endpoints
│   ├── orders.sv.jac       # 7 endpoints
│   ├── users.sv.jac        # 7 endpoints
│   └── reviews.sv.jac      # 3 endpoints
├── pages/
│   ├── CatalogPage.cl.jac  # /
│   ├── ProductPage.cl.jac  # /products/:id
│   ├── CartPage.cl.jac     # /cart
│   ├── OrdersPage.cl.jac   # /orders
│   └── SearchPage.cl.jac   # /search
├── components/
│   ├── Header.cl.jac
│   └── ProductCard.cl.jac
└── lib/
    └── utils.cl.jac        # cn(), format_price()
```

27 backend endpoints across 5 services. Graph data lives on `root()`;
endpoints traverse with `[root() -->][?:NodeType]` and mutate in place.

## Conventions for tasks

When implementing a task in this app:

1. Read the task `issue.md` to identify which service owns the change.
2. Open the relevant `services/<area>.sv.jac` and find the `def:pub`
   function named in the issue.
3. Edit in place. Every endpoint shares the same `root()`.
4. Helpers (`find_variant`, `find_user`, `find_payment_method`, etc.)
   are plain `def`, client-invisible. Reuse them.
5. Run `jac check main.jac` from `app/` to validate before submitting.

## Design decisions

- **No auth.** Frontend hardcodes `user_001` (Alice). Matches Python ref.
- **`def:pub` over `walker:pub`.** Cleaner client API
  (`await fn(args)` vs `root() spawn Walker(...).reports[0]`); preferred
  for simple CRUD.
- **Lazy seeding.** First endpoint call triggers `ensure_seeded()`.
  `with entry { seed_catalog(); }` runs in a different `root()` than
  per-request endpoints, so seed via `with entry` would never be visible.

## Known gotchas

- LSP often reports E1101/E1102/E1032 false positives on
  `Router/Routes/Route/Link/Navigate` and node attribute access. Trust
  `jac check`, not LSP.
- VS Code Code Helper holds port 8000 on macOS. Use `--port 9000`.
- `with entry { ... }` blocks the event loop in `jac start` mode. Do
  not use it for setup that needs to run on per-request `root()`.

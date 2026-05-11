# E-Commerce: Jac fullstack benchmark

Jac implementation of the JaseciBench e-commerce CodeAgentEval benchmark.

## Layout

```
jaclang/
├── app/      # Reference application (read-only; agents edit a working copy)
└── tasks/    # Per-task descriptions (issue.md, meta.public.json), coming soon
```

See [`app/README.md`](app/README.md) for the architecture, endpoints,
conventions, and quick-start.

## Status

- 🚧 Base app: in progress (porting from JaseciBenchmark experimental)
- 🚧 Tasks: Jac-specific task descriptions coming next
- 🚧 Vault tasks (`broken/`, `solution/`, `tests_hidden.jac`): coming next

## Pairs with

- `../python/`: equivalent FastAPI implementation
- `../../../JaseciBench-vault/oracle_jac/`: graders for Jac apps

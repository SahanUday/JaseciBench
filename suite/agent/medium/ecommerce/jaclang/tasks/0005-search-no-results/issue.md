# Show "no results" message when search returns nothing

When a user submits a search query that returns zero results, the
`/search` page silently shows nothing under the search box. The user is
left wondering whether the search ran, the network failed, or there
just are no matches. Add a visible "no products match" message for that
case.

## Bug location

`app/pages/SearchPage.cl.jac`. The component renders the loading
indicator and the results grid, but no block is rendered for the
zero-results case.

## Expected behaviour

When the user has submitted a search (`searched == True`), the search
is no longer in flight (`searching == False`), and `len(results) == 0`,
render a paragraph that contains the phrase `No products match` and the
user's `{query}` interpolated into the text.

The loading indicator and the results grid must continue to behave as
they do today.

## Example

After the user searches for "xyz123" (no products match):

```
No products match "xyz123".
```

## How to verify

```bash
cd suite/agent/medium/ecommerce/jaclang/app
jac check main.jac
jac start main.jac --port 9000
```

Open <http://localhost:9000/search> and search for an unlikely string.

"""Search page: search products by query."""

sv import from ..services.catalog { search_products }
import from ..components.ProductCard { ProductCard }


def:pub SearchPage() -> JsxElement {
    has query: str = "";
    has results: list = [];
    has searching: bool = False;
    has searched: bool = False;

    async def do_search(e: FormEvent) -> None {
        e.preventDefault();
        if not query.strip() { return; }
        searching = True;
        result = await search_products(query);
        results = result if result else [];
        searching = False;
        searched = True;
    }

    return <div className="max-w-6xl mx-auto px-6 py-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-6">Search Products</h1>

        <form onSubmit={do_search} className="flex gap-2 mb-8">
            <input
                type="text"
                value={query}
                onChange={lambda e: ChangeEvent { query = e.target.value; }}
                placeholder="Try 'shirt', 'coffee', 'wireless'..."
                className="flex-1 px-4 py-2.5 border border-gray-300 rounded-lg focus:outline-none focus:border-indigo-600 focus:ring-2 focus:ring-indigo-100"
            />
            <button
                type="submit"
                className="px-6 py-2.5 bg-indigo-600 hover:bg-indigo-700 text-white font-semibold rounded-lg"
            >
                Search
            </button>
        </form>

        {(<p className="text-gray-500">Searching...</p>) if searching else None}
        {(<div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
            {[<ProductCard key={p["id"]} product={p} /> for p in results]}
        </div>) if len(results) > 0 else None}
    </div>;
}

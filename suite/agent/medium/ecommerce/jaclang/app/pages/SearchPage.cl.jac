"""Search page: search products by query, category, and price."""

sv import from ..services.catalog { search_products, list_categories }
import from ..components.ProductCard { ProductCard }


def:pub SearchPage() -> JsxElement {
    has query: str = "";
    has category_id: str = "";
    has min_price: str = "";
    has max_price: str = "";
    has results: list = [];
    has categories: list = [];
    has searching: bool = False;
    has searched: bool = False;

    async can with entry {
        result = await list_categories();
        if result {
            categories = result;
        }
    }

    async def do_search(e: FormEvent) -> None {
        e.preventDefault();
        searching = True;
        # Convert price strings to floats, defaulting to 0.0 if empty
        min_p: float = float(min_price) if min_price.strip() else 0.0;
        max_p: float = float(max_price) if max_price.strip() else 0.0;
        result = await search_products(query, category_id, min_p, max_p);
        if result {
            results = result;
        }
        searching = False;
        searched = True;
    }

    return <div className="max-w-6xl mx-auto px-6 py-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-6">Search Products</h1>

        <form onSubmit={do_search} className="mb-8">
            <div className="flex flex-col gap-4 mb-6">
                <div className="flex gap-2">
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
                </div>

                <div className="flex gap-4 flex-wrap">
                    <select
                        value={category_id}
                        onChange={lambda e: ChangeEvent { category_id = e.target.value; }}
                        className="px-4 py-2.5 border border-gray-300 rounded-lg focus:outline-none focus:border-indigo-600 focus:ring-2 focus:ring-indigo-100"
                    >
                        <option value="">All Categories</option>
                        {[<option key={c["id"]} value={c["id"]}>{c["name"]}</option> for c in categories]}
                    </select>

                    <input
                        type="text"
                        value={min_price}
                        onChange={lambda e: ChangeEvent { min_price = e.target.value; }}
                        placeholder="Min Price"
                        className="w-32 px-4 py-2.5 border border-gray-300 rounded-lg focus:outline-none focus:border-indigo-600 focus:ring-2 focus:ring-indigo-100"
                    />

                    <input
                        type="text"
                        value={max_price}
                        onChange={lambda e: ChangeEvent { max_price = e.target.value; }}
                        placeholder="Max Price"
                        className="w-32 px-4 py-2.5 border border-gray-300 rounded-lg focus:outline-none focus:border-indigo-600 focus:ring-2 focus:ring-indigo-100"
                    />
                </div>
            </div>
        </form>

        {(<p className="text-gray-500">Searching...</p>) if searching else None}
        {(<p className="text-gray-600">No products match your search.</p>) if (searched and not searching and len(results) == 0) else None}
        {(<div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
            {[<ProductCard key={p["id"]} product={p} /> for p in results]}
        </div>) if len(results) > 0 else None}
    </div>;
}

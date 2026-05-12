"""Catalog page: list categories + products."""

sv import from ..services.catalog { list_categories, list_products }
import from ..components.ProductCard { ProductCard }


def:pub CatalogPage() -> JsxElement {
    has categories: list = [];
    has products: list = [];
    has loading: bool = True;
    has selected_cat: str = "";

    async can with entry {
        cats_result = await list_categories();
        categories = cats_result if cats_result else [];
        prods_result = await list_products("");
        products = prods_result if prods_result else [];
        loading = False;
    }

    async def select_category(cat_id: str) -> None {
        selected_cat = cat_id;
        loading = True;
        prods_result = await list_products(cat_id);
        products = prods_result if prods_result else [];
        loading = False;
    }

    return <div className="max-w-6xl mx-auto px-6 py-8">
        <div className="mb-8">
            <h1 className="text-3xl font-bold text-gray-900 tracking-tight">Catalog</h1>
            <p className="text-gray-600 mt-1">Browse our products by category.</p>
        </div>

        <div className="flex flex-wrap gap-2 mb-6">
            <button
                onClick={lambda e: select_category("")}
                className={"px-4 py-2 rounded-md font-medium transition-colors " + ("bg-blue-600 text-white" if selected_cat == "" else "bg-gray-200 text-gray-700 hover:bg-gray-300")}>
                All
            </button>
            {[<button
                key={cat["id"]}
                onClick={lambda e: select_category(str(cat["id"]))}
                className={"px-4 py-2 rounded-md font-medium transition-colors " + ("bg-blue-600 text-white" if selected_cat == str(cat["id"]) else "bg-gray-200 text-gray-700 hover:bg-gray-300")}>
                {f"{cat['name']} ({cat['product_count']})"}
            </button> for cat in categories]}
        </div>

        {(<p className="text-gray-500">Loading...</p>) if loading else None}
        {(<div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
            {[<ProductCard key={p["id"]} product={p} /> for p in products]}
        </div>) if not loading else None}
        {(<p className="text-gray-500 text-center py-12">No products in this category.</p>) if not loading and len(products) == 0 else None}
    </div>;
}

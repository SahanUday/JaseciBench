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

    async def handle_category_click(e: Any, cat_id: str) -> None {
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

        <div className="mb-6 flex flex-wrap gap-2">
            <button
                onClick={lambda e: handle_category_click(e, "")}
                className={"px-4 py-2 rounded-lg font-medium transition-colors " + ("bg-blue-600 text-white" if selected_cat == "" else "bg-gray-200 text-gray-800 hover:bg-gray-300")}
            >
                All
            </button>
            {[<CategoryButton key={i} cat={categories[i]} selected={selected_cat} on_click={handle_category_click} /> for i in range(len(categories))]}
        </div>

        {(<p className="text-gray-500">Loading...</p>) if loading else None}
        {(<div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
            {[<ProductCard key={p["id"]} product={p} /> for p in products]}
        </div>) if not loading else None}
        {(<p className="text-gray-500 text-center py-12">No products in this category.</p>) if not loading and len(products) == 0 else None}
    </div>;
}


def:pub CategoryButton(cat: Any, selected: str, on_click: Any) -> JsxElement {
    cat_id: str = str(cat["id"]);
    cat_name: str = str(cat["name"]);
    product_count: int = int(cat["product_count"]) if "product_count" in cat else 0;

    def handle_click(e: MouseEvent) -> None {
        on_click(e, cat_id);
    }

    return <button
        onClick={handle_click}
        className={"px-4 py-2 rounded-lg font-medium transition-colors " + ("bg-blue-600 text-white" if selected == cat_id else "bg-gray-200 text-gray-800 hover:bg-gray-300")}
    >
        {cat_name} ({product_count})
    </button>;
}

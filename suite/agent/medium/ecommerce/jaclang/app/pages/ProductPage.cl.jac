"""Product detail page: variants + add-to-cart."""

import from "@jac/runtime" { useParams, Link }
sv import from ..services.catalog { get_product }
sv import from ..services.cart { add_to_cart }


def:pub ProductPage() -> JsxElement {
    has product: Any = None;
    has loading: bool = True;
    has selected_variant_id: str = "";
    has feedback: str = "";

    params = useParams();
    pid = params["id"];

    async can with entry {
        result = await get_product(pid);
        product = result;
        loading = False;
        if product != None and len(product["variants"]) > 0 {
            selected_variant_id = product["variants"][0]["id"];
        }
    }

    async def add_to_cart_handler(_e: MouseEvent) -> None {
        if not selected_variant_id { return; }
        feedback = "Adding...";
        result = await add_to_cart("user_001", selected_variant_id, 1);
        if result and "error" in result {
            feedback = "Error: " + str(result["error"]);
        } else {
            feedback = "Added to cart!";
        }
    }

    if loading {
        return <div className="max-w-4xl mx-auto px-6 py-12 text-gray-500">Loading...</div>;
    }
    if product == None {
        return <div className="max-w-4xl mx-auto px-6 py-12">
            <p className="text-gray-700">Product not found.</p>
            <Link to="/" className="text-indigo-600 hover:underline mt-4 inline-block">← Back to catalog</Link>
        </div>;
    }

    return <div className="max-w-4xl mx-auto px-6 py-8">
        <Link to="/" className="text-sm text-indigo-600 hover:underline">← Back to catalog</Link>

        <div className="mt-6 grid grid-cols-1 md:grid-cols-2 gap-8">
            <div className="aspect-square bg-gradient-to-br from-gray-100 to-gray-50 rounded-2xl flex items-center justify-center text-gray-300 text-7xl font-light">
                {product["name"][0:1]}
            </div>

            <div>
                <h1 className="text-3xl font-bold text-gray-900">{product["name"]}</h1>
                <p className="text-gray-600 mt-2 leading-relaxed">{product["description"]}</p>

                {(
                    <div className="mt-5 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-red-800">
                        <div className="font-semibold">Currently unavailable</div>
                        <div className="text-sm mt-1 text-red-700">All variants for this product are out of stock.</div>
                    </div>
                ) if (sum([v["stock_qty"] for v in product["variants"]]) == 0) else None}

                <div className="mt-6">
                    <h3 className="text-sm font-semibold text-gray-900 mb-2">Variants</h3>
                    <div className="space-y-2">
                        {[<button
                            key={v["id"]}
                            onClick={lambda _e: MouseEvent { selected_variant_id = v["id"]; }}
                            className={"w-full text-left p-3 rounded-lg border transition-colors " + ("border-indigo-600 bg-indigo-50" if selected_variant_id == v["id"] else "border-gray-200 hover:border-gray-300")}
                        >
                            <div className="flex items-center justify-between">
                                <div>
                                    <div className="text-sm font-medium text-gray-900">
                                        {v["color"] + " · " + v["size"]}
                                    </div>
                                    <div className="text-xs text-gray-500 mt-0.5">
                                        {v["material"] + " · " + str(v["stock_qty"]) + " in stock"}
                                    </div>
                                </div>
                                <span className="text-sm font-bold text-gray-900">
                                    {"$" + str(v["price"])}
                                </span>
                            </div>
                        </button> for v in product["variants"]]}
                    </div>
                </div>

                <button
                    onClick={add_to_cart_handler}
                    disabled={selected_variant_id == ""}
                    className="w-full mt-6 py-3 bg-indigo-600 hover:bg-indigo-700 text-white font-semibold rounded-lg transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                >
                    Add to Cart
                </button>
                {(<p className="mt-3 text-sm text-center text-gray-700">{feedback}</p>) if feedback else None}
            </div>
        </div>
    </div>;
}

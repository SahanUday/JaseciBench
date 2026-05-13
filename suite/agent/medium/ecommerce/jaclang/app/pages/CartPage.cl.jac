"""Cart page: view + mutate cart, checkout."""

import from "@jac/runtime" { Link, useNavigate }
sv import from ..services.cart { get_cart, update_cart_item, remove_from_cart, checkout }


def:pub CartPage() -> JsxElement {
    has cart: Any = None;
    has loading: bool = True;
    has checking_out: bool = False;
    has feedback: str = "";

    nav = useNavigate();

    async def refresh() -> None {
        result = await get_cart("user_001");
        cart = result if result else {"items": [], "total": 0.0, "count": 0};
        loading = False;
    }

    async can with entry {
        await refresh();
    }

    async def update_qty(item_id: str, qty: int) -> None {
        await update_cart_item(item_id, qty);
        await refresh();
    }

    async def remove_item(item_id: str) -> None {
        await remove_from_cart(item_id);
        await refresh();
    }

    async def do_checkout(_e: MouseEvent) -> None {
        checking_out = True;
        result = await checkout("user_001", "pm_001", "123 Main St", "New York", "NY", "10001");
        checking_out = False;
        if result and "error" in result {
            feedback = "Error: " + str(result["error"]);
        } else {
            nav("/orders");
        }
    }

    if loading {
        return <div className="max-w-4xl mx-auto px-6 py-12 text-gray-500">Loading...</div>;
    }

    items: Any = cart["items"] if cart else [];

    return <div className="max-w-4xl mx-auto px-6 py-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-6">Shopping Cart</h1>

        {(<div className="p-8 bg-white border border-gray-200 rounded-xl text-center">
            <div className="text-lg font-semibold text-gray-900">Your cart is empty.</div>
            <div className="mt-2 text-sm text-gray-600">Add something you like to get started.</div>
            <div className="mt-6">
                <a href="/" className="inline-flex items-center justify-center px-5 py-2.5 rounded-lg bg-indigo-600 hover:bg-indigo-700 text-white font-semibold transition-colors">
                    Browse products
                </a>
            </div>
        </div>) if (not items or len(items) == 0) else None}

        {(<div>
            <div className="space-y-3">
                {[<div key={item["id"]} className="flex items-center gap-4 p-4 bg-white border border-gray-200 rounded-xl">
                    <div className="w-16 h-16 bg-gradient-to-br from-gray-100 to-gray-50 rounded-lg flex items-center justify-center text-gray-300 text-xl font-light">
                        {item["color"][0:1] if item["color"] else "?"}
                    </div>
                    <div className="flex-1 min-w-0">
                        <div className="text-sm font-semibold text-gray-900">
                            {item["color"] + " · " + item["size"]}
                        </div>
                        <div className="text-xs text-gray-500 mt-0.5">
                            {"$" + str(item["price"]) + " each"}
                        </div>
                    </div>
                    <div className="flex items-center gap-2">
                        <button
                            onClick={lambda _e: MouseEvent { update_qty(item["id"], item["quantity"] - 1); }}
                            className="w-8 h-8 rounded border border-gray-300 hover:bg-gray-50 text-gray-600"
                        >−</button>
                        <span className="w-8 text-center text-sm font-medium">{item["quantity"]}</span>
                        <button
                            onClick={lambda _e: MouseEvent { update_qty(item["id"], item["quantity"] + 1); }}
                            className="w-8 h-8 rounded border border-gray-300 hover:bg-gray-50 text-gray-600"
                        >+</button>
                    </div>
                    <div className="w-24 text-right text-sm font-semibold text-gray-900">
                        {"$" + str(item["subtotal"])}
                    </div>
                    <button
                        onClick={lambda _e: MouseEvent { remove_item(item["id"]); }}
                        className="text-gray-400 hover:text-red-600 text-sm"
                    >Remove</button>
                </div> for item in items]}
            </div>

            <div className="mt-6 p-5 bg-gray-50 rounded-xl flex items-center justify-between">
                <div className="space-y-1">
                    <div className="flex items-center justify-between gap-6 text-sm text-gray-700">
                        <span>Subtotal</span>
                        <span className="font-medium text-gray-900">{"$" + str(cart["total"])}</span>
                    </div>
                    <div className="flex items-center justify-between gap-6 text-sm text-gray-700">
                        <span>Shipping</span>
                        <span className="font-medium text-gray-900">{"$" + str(cart["shipping"])}</span>
                    </div>
                    <div className="pt-2 flex items-center justify-between gap-6">
                        <span className="text-sm font-semibold text-gray-900">Grand total</span>
                        <span className="text-2xl font-bold text-gray-900">{"$" + str(cart["grand_total"])}</span>
                    </div>
                </div>
                <button
                    onClick={do_checkout}
                    disabled={checking_out}
                    className="px-6 py-2.5 bg-indigo-600 hover:bg-indigo-700 text-white font-semibold rounded-lg transition-colors disabled:opacity-50"
                >
                    {("Processing..." if checking_out else "Checkout")}
                </button>
            </div>
            {(<p className="mt-3 text-sm text-center text-red-600">{feedback}</p>) if feedback else None}
        </div>) if len(items) > 0 else None}
    </div>;
}

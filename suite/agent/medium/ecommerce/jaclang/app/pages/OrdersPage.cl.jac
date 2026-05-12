"""Orders page: list user orders + cancel."""

import from "@jac/runtime" { Link }
sv import from ..services.orders { list_orders, cancel_order }


def status_color(status: str) -> str {
    colors: dict[str, str] = {
        "delivered": "bg-green-100 text-green-700",
        "shipped": "bg-blue-100 text-blue-700",
        "processed": "bg-yellow-100 text-yellow-700",
        "pending": "bg-gray-100 text-gray-700",
        "cancelled": "bg-red-100 text-red-700",
        "returned": "bg-purple-100 text-purple-700"
    };
    return colors.get(status, "bg-gray-100 text-gray-700");
}


def:pub OrdersPage() -> JsxElement {
    has orders: list = [];
    has loading: bool = True;

    async def refresh() -> None {
        result = await list_orders("user_001");
        orders = result if result else [];
        loading = False;
    }

    async can with entry {
        await refresh();
    }

    async def do_cancel(order_id: str) -> None {
        await cancel_order(order_id);
        await refresh();
    }

    if loading {
        return <div className="max-w-4xl mx-auto px-6 py-12 text-gray-500">Loading...</div>;
    }

    return <div className="max-w-4xl mx-auto px-6 py-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-6">Your Orders</h1>

        {(<div className="text-center py-12">
            <p className="text-gray-500 mb-4">No orders yet.</p>
            <Link to="/" className="inline-block px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors">
                Browse products
            </Link>
        </div>) if len(orders) == 0 else None}

        <div className="space-y-3">
            {[<div key={o["id"]} className="p-4 bg-white border border-gray-200 rounded-xl">
                <div className="flex items-start justify-between gap-4">
                    <div className="min-w-0">
                        <Link to={"/orders/" + o["id"]} className="text-sm font-bold text-blue-600 hover:underline">
                            {o["id"]}
                        </Link>
                        <div className="text-xs text-gray-500 mt-0.5">{o["created_at"]}</div>
                        <div className="text-xs text-gray-600 mt-2">
                            {o["shipping_address1"] + ", " + o["shipping_city"] + ", " + o["shipping_state"] + " " + o["shipping_zip"]}
                        </div>
                        <div className="text-xs text-gray-500 mt-1">
                            {str(o["item_count"]) + " items"}
                        </div>
                        <div className="text-xs text-gray-600 mt-1">
                            {"Paid: $" + str(o["total_paid"])}
                        </div>
                    </div>
                    <div className="flex flex-col items-end gap-2">
                        <span className={"text-xs rounded-full px-2.5 py-1 " + status_color(o["status"])}>
                            {o["status"]}
                        </span>
                        {(<button
                            onClick={lambda _e: MouseEvent { do_cancel(o["id"]); }}
                            className="text-xs text-red-600 hover:text-red-700 hover:underline"
                        >Cancel</button>) if o["status"] in ["pending", "processed"] else None}
                    </div>
                </div>
            </div> for o in orders]}
        </div>
    </div>;
}

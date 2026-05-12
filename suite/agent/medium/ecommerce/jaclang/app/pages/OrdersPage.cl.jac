"""Orders page: list user orders + cancel."""

sv import from ..services.orders { list_orders, cancel_order }


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

        {(<p className="text-gray-500 text-center py-12">No orders yet.</p>) if len(orders) == 0 else None}

        <div className="space-y-3">
            {[<div key={o["id"]} className="p-4 bg-white border border-gray-200 rounded-xl">
                <div className="flex items-start justify-between gap-4">
                    <div className="min-w-0">
                        <div className="text-sm font-bold text-gray-900">{o["id"]}</div>
                        <div className="text-xs text-gray-500 mt-0.5">{o["created_at"]}</div>
                        <div className="text-xs text-gray-600 mt-2">
                            {o["shipping_address1"] + ", " + o["shipping_city"] + ", " + o["shipping_state"] + " " + o["shipping_zip"]}
                        </div>
                    </div>
                    <div className="flex flex-col items-end gap-2">
                        <span className="text-xs text-gray-600">
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

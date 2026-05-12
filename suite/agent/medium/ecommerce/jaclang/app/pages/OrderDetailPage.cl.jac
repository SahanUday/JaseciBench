"""Order detail page: view order items, payments, and cancel."""

import from "@jac/runtime" { Link, useParams, useNavigate }
sv import from ..services.orders { get_order, cancel_order }


def status_color(status: str) -> str {
    return "bg-green-100 text-green-700" if status == "delivered" else "bg-blue-100 text-blue-700" if status == "shipped" else "bg-yellow-100 text-yellow-700" if status == "processed" else "bg-gray-100 text-gray-700" if status == "pending" else "bg-red-100 text-red-700" if status == "cancelled" else "bg-purple-100 text-purple-700" if status == "returned" else "bg-gray-100 text-gray-700";
}


def:pub OrderDetailPage() -> JsxElement {
    has order: Any = None;
    has loading: bool = True;

    params = useParams();
    nav = useNavigate();
    order_id = params["id"];

    async def load_order() -> None {
        if order_id {
            result = await get_order(str(order_id));
            order = result;
            loading = False;
        }
    }

    async can with entry {
        await load_order();
    }

    async def do_cancel() -> None {
        if order_id {
            await cancel_order(str(order_id));
            await load_order();
        }
    }

    if loading {
        return <div className="max-w-4xl mx-auto px-6 py-12 text-gray-500">Loading...</div>;
    }

    if not order {
        return <div className="max-w-4xl mx-auto px-6 py-12">
            <p className="text-gray-500 mb-4">Order not found.</p>
            <Link to="/orders" className="text-blue-600 hover:underline">← Back to orders</Link>
        </div>;
    }

    items = order["items"] if order and "items" in order else [];
    payments = order["payments"] if order and "payments" in order else [];
    grand_total = order["total"] if order and "total" in order else 0.0;

    return <div className="max-w-4xl mx-auto px-6 py-8">
        <div className="mb-6">
            <Link to="/orders" className="text-sm text-blue-600 hover:underline mb-2 inline-block">
                ← Back to orders
            </Link>
            <h1 className="text-3xl font-bold text-gray-900">Order Details</h1>
        </div>

        <div className="bg-white border border-gray-200 rounded-xl p-6 mb-6">
            <div className="flex items-start justify-between mb-4">
                <div>
                    <div className="text-sm text-gray-500">Order ID</div>
                    <div className="text-lg font-bold text-gray-900">{order["id"]}</div>
                </div>
                <span className={f"text-sm px-3 py-1.5 rounded-full {status_color(str(order['status']))}"}>
                    {order["status"]}
                </span>
            </div>

            <div className="border-t border-gray-200 pt-4">
                <div className="text-sm text-gray-500 mb-1">Shipping Address</div>
                <div className="text-sm text-gray-900">
                    {str(order["shipping_address1"])}
                    {(", " + str(order["shipping_address2"])) if order["shipping_address2"] else ""}
                </div>
                <div className="text-sm text-gray-900">
                    {str(order["shipping_city"]) + ", " + str(order["shipping_state"]) + " " + str(order["shipping_zip"])}
                </div>
            </div>
        </div>

        <div className="bg-white border border-gray-200 rounded-xl p-6 mb-6">
            <h2 className="text-xl font-bold text-gray-900 mb-4">Order Items</h2>
            {(<div className="text-gray-500 text-sm">No items in this order.</div>) if len(items) == 0 else None}
            <div className="space-y-3">
                {[<div key={item["id"]} className="flex justify-between items-start py-3 border-b border-gray-100 last:border-0">
                    <div className="flex-1">
                        <div className="text-sm font-medium text-gray-900">Variant {item["variant_id"]}</div>
                        <div className="text-xs text-gray-500 mt-1">
                            Quantity: {str(item["quantity"])} × ${str(item["price_snapshot"])}
                        </div>
                        {(<span className="text-xs text-red-600 mt-1 inline-block">Returned</span>) if item["returned"] else None}
                    </div>
                    <div className="text-sm font-bold text-gray-900">
                        ${str(item["subtotal"])}
                    </div>
                </div> for item in items]}
            </div>
            <div className="border-t border-gray-300 pt-4 mt-4">
                <div className="flex justify-between items-center">
                    <div className="text-base font-bold text-gray-900">Grand Total</div>
                    <div className="text-lg font-bold text-gray-900">${str(grand_total)}</div>
                </div>
            </div>
        </div>

        <div className="bg-white border border-gray-200 rounded-xl p-6 mb-6">
            <h2 className="text-xl font-bold text-gray-900 mb-4">Payments</h2>
            {(<div className="text-gray-500 text-sm">No payments recorded.</div>) if len(payments) == 0 else None}
            <div className="space-y-2">
                {[<div key={p["id"]} className="flex justify-between items-center text-sm py-2 border-b border-gray-100 last:border-0">
                    <div>
                        <span className="font-medium text-gray-900 capitalize">{p["transaction_type"]}</span>
                        <span className="text-gray-500 ml-2 text-xs">{p["created_at"]}</span>
                    </div>
                    <div className={f"font-bold {'text-green-600' if p['transaction_type'] == 'payment' else 'text-red-600'}"}>
                        {("+" if p["transaction_type"] == "payment" else "-") + "$" + str(p["amount"])}
                    </div>
                </div> for p in payments]}
            </div>
        </div>

        {(<div className="flex justify-end">
            <button
                onClick={lambda _e: MouseEvent { do_cancel(); }}
                className="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700"
            >
                Cancel Order
            </button>
        </div>) if order["status"] == "pending" else None}
    </div>;
}

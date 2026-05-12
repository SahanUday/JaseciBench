"""Order detail page: show line items, payments, and cancel button."""

import from "@jac/runtime" { Link, useParams, useNavigate }
sv import from ..services.orders { get_order, cancel_order }


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


def:pub OrderDetailPage() -> JsxElement {
    has order: Any = None;
    has loading: bool = True;

    params = useParams();
    nav = useNavigate();
    order_id = params["id"];

    async def refresh() -> None {
        if order_id is not None {
            result = await get_order(order_id);
            order = result;
            loading = False;
        }
    }

    async can with entry {
        await refresh();
    }

    async def do_cancel(oid: str) -> None {
        await cancel_order(oid);
        await refresh();
    }

    if loading {
        return <div className="max-w-4xl mx-auto px-6 py-12 text-gray-500">Loading...</div>;
    }

    if order is None {
        return <div className="max-w-4xl mx-auto px-6 py-12">
            <p className="text-gray-500 mb-4">Order not found.</p>
            <Link to="/orders" className="text-blue-600 hover:underline">← Back to orders</Link>
        </div>;
    }

    total_paid = 0.0;
    for p in order["payments"] {
        if p["transaction_type"] == "payment" {
            total_paid = total_paid + p["amount"];
        } elif p["transaction_type"] == "refund" {
            total_paid = total_paid - p["amount"];
        }
    }
    total_paid = int(total_paid * 100) / 100.0;

    return <div className="max-w-4xl mx-auto px-6 py-8">
        <div className="mb-6">
            <Link to="/orders" className="text-blue-600 hover:underline text-sm">← Back to orders</Link>
        </div>

        <div className="bg-white border border-gray-200 rounded-xl p-6 mb-6">
            <div className="flex items-start justify-between mb-4">
                <div>
                    <h1 className="text-2xl font-bold text-gray-900">Order {order["id"]}</h1>
                    <div className="text-sm text-gray-500 mt-1">{order["created_at"]}</div>
                </div>
                <span className={"text-sm rounded-full px-3 py-1 " + status_color(order["status"])}>
                    {order["status"]}
                </span>
            </div>

            <div className="border-t border-gray-200 pt-4">
                <h2 className="text-sm font-semibold text-gray-700 mb-2">Shipping Address</h2>
                <div className="text-sm text-gray-600">
                    {order["shipping_address1"]}
                    {(", " + order["shipping_address2"]) if order["shipping_address2"] else ""}
                    <br />
                    {order["shipping_city"] + ", " + order["shipping_state"] + " " + order["shipping_zip"]}
                    {(", " + order["shipping_country"]) if order["shipping_country"] else ""}
                </div>
            </div>
        </div>

        <div className="bg-white border border-gray-200 rounded-xl p-6 mb-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">Order Items</h2>
            <div className="space-y-3">
                {[<div key={item["id"]} className="flex justify-between items-start py-3 border-b border-gray-100 last:border-b-0">
                    <div className="flex-1">
                        <div className="text-sm font-medium text-gray-900">Variant {item["variant_id"]}</div>
                        <div className="text-xs text-gray-500 mt-1">
                            {"Quantity: " + str(item["quantity"]) + " × $" + str(item["price_snapshot"])}
                        </div>
                        {(<span className="text-xs text-red-600">Returned</span>) if item["returned"] else None}
                    </div>
                    <div className="text-sm font-semibold text-gray-900">
                        {"$" + str(item["subtotal"])}
                    </div>
                </div> for item in order["items"]]}
            </div>
            <div className="mt-4 pt-4 border-t border-gray-200 flex justify-between">
                <span className="text-base font-bold text-gray-900">Total</span>
                <span className="text-base font-bold text-gray-900">{"$" + str(order["total"])}</span>
            </div>
        </div>

        <div className="bg-white border border-gray-200 rounded-xl p-6 mb-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">Payments</h2>
            <div className="space-y-2">
                {[<div key={pay["id"]} className="flex justify-between text-sm">
                    <div>
                        <span className="text-gray-700">{pay["transaction_type"]}</span>
                        <span className="text-gray-500 ml-2">{pay["created_at"]}</span>
                    </div>
                    <span className={"font-medium " + ("text-green-600" if pay["transaction_type"] == "payment" else "text-red-600")}>
                        {("+" if pay["transaction_type"] == "payment" else "-") + "$" + str(pay["amount"])}
                    </span>
                </div> for pay in order["payments"]]}
            </div>
            <div className="mt-4 pt-4 border-t border-gray-200 flex justify-between">
                <span className="text-base font-bold text-gray-900">Total Paid</span>
                <span className="text-base font-bold text-gray-900">{"$" + str(total_paid)}</span>
            </div>
        </div>

        {(<div className="flex justify-end">
            <button
                onClick={lambda _e: MouseEvent { do_cancel(order["id"]); }}
                className="px-6 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors"
            >Cancel Order</button>
        </div>) if order["status"] == "pending" else None}
    </div>;
}

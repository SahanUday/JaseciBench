"""Order detail page: view single order with line items and payments."""

import from "@jac/runtime" { Link, useParams }

sv import from ..services.orders { get_order, cancel_order }


def status_color(status: str) -> str {
    if status == "delivered" {
        return "bg-green-100 text-green-700";
    }
    if status == "shipped" {
        return "bg-blue-100 text-blue-700";
    }
    if status == "processed" {
        return "bg-yellow-100 text-yellow-700";
    }
    if status == "pending" {
        return "bg-gray-100 text-gray-700";
    }
    if status == "cancelled" {
        return "bg-red-100 text-red-700";
    }
    if status == "returned" {
        return "bg-purple-100 text-purple-700";
    }
    return "bg-gray-100 text-gray-700";
}


def:pub OrderDetailPage() -> JsxElement {
    params = useParams();
    has order: Any = None;
    has loading: bool = True;

    async def refresh() -> None {
        oid = params["id"];
        if oid != None {
            result = await get_order(oid);
            order = result;
        }
        loading = False;
    }

    async can with entry {
        await refresh();
    }

    async def do_cancel() -> None {
        oid = params["id"];
        if oid != None {
            await cancel_order(oid);
            await refresh();
        }
    }

    if loading {
        return <div className="max-w-4xl mx-auto px-6 py-12 text-gray-500">Loading...</div>;
    }

    if order == None {
        return <div className="max-w-4xl mx-auto px-6 py-12">
            <h1 className="text-2xl font-bold text-gray-900 mb-4">Order Not Found</h1>
            <Link to="/orders" className="text-blue-600 hover:underline">← Back to Orders</Link>
        </div>;
    }

    return <div className="max-w-4xl mx-auto px-6 py-8">
        <div className="mb-6">
            <Link to="/orders" className="text-blue-600 hover:underline text-sm">← Back to Orders</Link>
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
                    <div>{order["shipping_address1"]}</div>
                    {(order["shipping_address2"] if order["shipping_address2"] else None) and <div>{order["shipping_address2"]}</div>}
                    <div>{order["shipping_city"] + ", " + order["shipping_state"] + " " + order["shipping_zip"]}</div>
                    {(order["shipping_country"] if order["shipping_country"] else None) and <div>{order["shipping_country"]}</div>}
                </div>
            </div>
        </div>

        <div className="bg-white border border-gray-200 rounded-xl p-6 mb-6">
            <h2 className="text-lg font-bold text-gray-900 mb-4">Order Items</h2>
            {(order["items"] if order["items"] else []) and len(order["items"]) > 0 and <div className="space-y-3">
                {[<div key={item["id"]} className="flex items-center justify-between py-3 border-b border-gray-100 last:border-0">
                    <div className="flex-1">
                        <div className="text-sm font-medium text-gray-900">Variant {item["variant_id"]}</div>
                        <div className="text-xs text-gray-500 mt-1">
                            {"Quantity: " + str(item["quantity"]) + " × $" + str(item["price_snapshot"])}
                        </div>
                        {item["returned"] and <span className="inline-block text-xs bg-red-100 text-red-700 px-2 py-0.5 rounded mt-1">Returned</span>}
                    </div>
                    <div className="text-sm font-semibold text-gray-900">
                        {"$" + str(item["subtotal"])}
                    </div>
                </div> for item in order["items"]]}
            </div>}

            <div className="border-t border-gray-300 mt-4 pt-4">
                <div className="flex items-center justify-between text-lg font-bold text-gray-900">
                    <span>Total</span>
                    <span>{"$" + str(order["total"])}</span>
                </div>
            </div>
        </div>

        {(order["payments"] if order["payments"] else []) and len(order["payments"]) > 0 and <div className="bg-white border border-gray-200 rounded-xl p-6 mb-6">
            <h2 className="text-lg font-bold text-gray-900 mb-4">Payments</h2>
            <div className="space-y-2">
                {[<div key={p["id"]} className="flex items-center justify-between py-2 text-sm">
                    <div>
                        <span className="font-medium text-gray-900">{p["transaction_type"]}</span>
                        <span className="text-gray-500 ml-2">{p["created_at"]}</span>
                    </div>
                    <span className={"font-semibold " + ("text-green-600" if p["transaction_type"] == "payment" else "text-red-600")}>
                        {(("+" if p["transaction_type"] == "payment" else "-") if p["transaction_type"] in ["payment", "refund"] else "") + "$" + str(p["amount"])}
                    </span>
                </div> for p in order["payments"]]}
            </div>
        </div>}

        {order["status"] == "pending" and <div className="flex justify-end">
            <button
                onClick={lambda _e: MouseEvent { do_cancel(); }}
                className="px-6 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors"
            >
                Cancel Order
            </button>
        </div>}
    </div>;
}

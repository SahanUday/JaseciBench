"""Order detail page: show order with line items, payments, and cancel button."""

import from "@jac/runtime" { Link, useParams }
sv import from ..services.orders { get_order, cancel_order }


def status_color(status: str) -> str {
    """Map order status to Tailwind color classes."""
    if status == "delivered" {
        return "bg-green-100 text-green-700";
    } elif status == "shipped" {
        return "bg-blue-100 text-blue-700";
    } elif status == "processed" {
        return "bg-yellow-100 text-yellow-700";
    } elif status == "pending" {
        return "bg-gray-100 text-gray-700";
    } elif status == "cancelled" {
        return "bg-red-100 text-red-700";
    } elif status == "returned" {
        return "bg-purple-100 text-purple-700";
    } else {
        return "bg-gray-100 text-gray-700";
    }
}


def:pub OrderDetailPage() -> JsxElement {
    has order: Any = None;
    has loading: bool = True;

    async def refresh() -> None {
        params = useParams();
        oid = params["id"];
        result = await get_order(oid);
        order = result;
        loading = False;
    }

    async can with entry {
        await refresh();
    }

    async def do_cancel() -> None {
        params = useParams();
        oid = params["id"];
        await cancel_order(oid);
        await refresh();
    }

    if loading {
        return <div className="max-w-4xl mx-auto px-6 py-12 text-gray-500">Loading...</div>;
    }

    if order is None {
        return <div className="max-w-4xl mx-auto px-6 py-12">
            <div className="text-center">
                <p className="text-gray-500 mb-4">Order not found.</p>
                <Link to="/orders" className="inline-block px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors">
                    Back to orders
                </Link>
            </div>
        </div>;
    }

    grand_total = order["total"] if "total" in order else 0.0;

    return <div className="max-w-4xl mx-auto px-6 py-8">
        <div className="mb-6">
            <Link to="/orders" className="inline-flex items-center text-blue-600 hover:text-blue-700 hover:underline text-sm mb-4">
                <span className="mr-1">←</span> Back to orders
            </Link>
            <h1 className="text-3xl font-bold text-gray-900">Order Details</h1>
        </div>

        <div className="bg-white border border-gray-200 rounded-xl p-6 mb-6">
            <div className="flex items-start justify-between mb-4">
                <div>
                    <div className="text-sm font-semibold text-gray-500">Order ID</div>
                    <div className="text-lg font-bold text-gray-900">{order["id"]}</div>
                    <div className="text-xs text-gray-500 mt-1">{order["created_at"]}</div>
                </div>
                <span className={"text-xs rounded-full px-2.5 py-1 " + status_color(order["status"])}>
                    {order["status"]}
                </span>
            </div>

            <div className="mb-4">
                <div className="text-sm font-semibold text-gray-700 mb-1">Shipping Address</div>
                <div className="text-sm text-gray-600">
                    {order["shipping_address1"]}
                    {(", " + order["shipping_address2"]) if order["shipping_address2"] else ""}
                </div>
                <div className="text-sm text-gray-600">
                    {order["shipping_city"] + ", " + order["shipping_state"] + " " + order["shipping_zip"]}
                </div>
                {(<div className="text-sm text-gray-600">{order["shipping_country"]}</div>) if "shipping_country" in order and order["shipping_country"] else None}
            </div>

            {(<button
                onClick={lambda _e: MouseEvent { do_cancel(); }}
                className="px-4 py-2 bg-red-600 text-white text-sm rounded-lg hover:bg-red-700 transition-colors"
            >Cancel Order</button>) if order["status"] == "pending" else None}
        </div>

        <div className="bg-white border border-gray-200 rounded-xl p-6 mb-6">
            <h2 className="text-xl font-bold text-gray-900 mb-4">Order Items</h2>
            <div className="space-y-3">
                {[<div key={item["id"]} className="flex justify-between items-start py-2 border-b border-gray-100 last:border-0">
                    <div>
                        <div className="text-sm font-medium text-gray-900">Variant {item["variant_id"]}</div>
                        <div className="text-xs text-gray-500">Quantity: {str(item["quantity"])}</div>
                        <div className="text-xs text-gray-500">Price: ${str(item["price_snapshot"])}</div>
                        {(<span className="text-xs text-red-600">Returned</span>) if item["returned"] else None}
                    </div>
                    <div className="text-sm font-semibold text-gray-900">
                        ${str(round(item["subtotal"], 2))}
                    </div>
                </div> for item in order["items"]]}
            </div>
            <div className="mt-4 pt-4 border-t border-gray-200 flex justify-between items-center">
                <span className="text-lg font-bold text-gray-900">Grand Total</span>
                <span className="text-lg font-bold text-gray-900">${str(round(grand_total, 2))}</span>
            </div>
        </div>

        {(<div className="bg-white border border-gray-200 rounded-xl p-6">
            <h2 className="text-xl font-bold text-gray-900 mb-4">Payments</h2>
            <div className="space-y-2">
                {[<div key={p["id"]} className="flex justify-between items-center py-2 border-b border-gray-100 last:border-0">
                    <div>
                        <div className="text-sm font-medium text-gray-900">{p["transaction_type"].capitalize()}</div>
                        <div className="text-xs text-gray-500">{p["created_at"]}</div>
                        <div className="text-xs text-gray-500">Method: {p["payment_method_id"]}</div>
                    </div>
                    <div className={"text-sm font-semibold " + ("text-green-600" if p["transaction_type"] == "payment" else "text-red-600")}>
                        {("+" if p["transaction_type"] == "payment" else "-") + "$" + str(round(p["amount"], 2))}
                    </div>
                </div> for p in order["payments"]]}
            </div>
        </div>) if "payments" in order and len(order["payments"]) > 0 else None}
    </div>;
}

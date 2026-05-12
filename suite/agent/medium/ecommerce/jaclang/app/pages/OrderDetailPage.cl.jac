"""Order detail page: view single order with items and payments."""

import from "@jac/runtime" { Link, useParams, useNavigate }
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
    has order: Any = None;
    has loading: bool = True;

    params = useParams();
    nav = useNavigate();
    order_id = params["id"];

    async def refresh() -> None {
        if order_id {
            result = await get_order(str(order_id));
            order = result;
        }
        loading = False;
    }

    async can with entry {
        await refresh();
    }

    async def do_cancel() -> None {
        if order_id {
            await cancel_order(str(order_id));
            nav("/orders");
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
            <Link to="/orders" className="text-blue-600 hover:underline text-sm">← Back to orders</Link>
        </div>

        <div className="bg-white border border-gray-200 rounded-xl p-6 mb-6">
            <div className="flex items-start justify-between mb-4">
                <div>
                    <h1 className="text-2xl font-bold text-gray-900">Order {order["id"]}</h1>
                    <p className="text-sm text-gray-500 mt-1">{order["created_at"]}</p>
                </div>
                <span className={"text-sm rounded-full px-3 py-1 " + status_color(order["status"])}>
                    {order["status"]}
                </span>
            </div>

            <div className="border-t border-gray-200 pt-4">
                <h2 className="text-sm font-semibold text-gray-700 mb-2">Shipping Address</h2>
                <p className="text-sm text-gray-600">
                    {str(order["shipping_address1"])}<br />
                    {(str(order["shipping_address2"]) + "<br />") if order.get("shipping_address2") else ""}
                    {str(order["shipping_city"]) + ", " + str(order["shipping_state"]) + " " + str(order["shipping_zip"])}<br />
                    {str(order["shipping_country"]) if order.get("shipping_country") else ""}
                </p>
            </div>
        </div>

        <div className="bg-white border border-gray-200 rounded-xl p-6 mb-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">Order Items</h2>
            {(<p className="text-gray-500 text-sm">No items in this order.</p>) if len(items) == 0 else None}
            <div className="space-y-3">
                {[<div key={item["id"]} className="flex justify-between items-center py-2 border-b border-gray-100 last:border-0">
                    <div className="flex-1">
                        <p className="text-sm font-medium text-gray-900">Variant {item["variant_id"]}</p>
                        <p className="text-xs text-gray-500">
                            Quantity: {str(item["quantity"])} × ${str(item["price_snapshot"])}
                            {(" (Returned)" if item["returned"] else "")}
                        </p>
                    </div>
                    <p className="text-sm font-semibold text-gray-900">${str(item["subtotal"])}</p>
                </div> for item in items]}
            </div>
            <div className="border-t border-gray-200 mt-4 pt-4">
                <div className="flex justify-between items-center">
                    <span className="text-base font-bold text-gray-900">Grand Total</span>
                    <span className="text-base font-bold text-gray-900">${str(grand_total)}</span>
                </div>
            </div>
        </div>

        <div className="bg-white border border-gray-200 rounded-xl p-6 mb-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">Payments</h2>
            {(<p className="text-gray-500 text-sm">No payments recorded.</p>) if len(payments) == 0 else None}
            <div className="space-y-2">
                {[<div key={pay["id"]} className="flex justify-between items-center py-2 border-b border-gray-100 last:border-0">
                    <div className="flex-1">
                        <p className="text-sm font-medium text-gray-900">{pay["transaction_type"]}</p>
                        <p className="text-xs text-gray-500">{pay["created_at"]}</p>
                    </div>
                    <p className="text-sm font-semibold text-gray-900">${str(pay["amount"])}</p>
                </div> for pay in payments]}
            </div>
        </div>

        {(<div className="flex justify-end">
            <button
                onClick={lambda _e: MouseEvent { do_cancel(); }}
                className="px-6 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors"
            >
                Cancel Order
            </button>
        </div>) if order["status"] == "pending" else None}
    </div>;
}

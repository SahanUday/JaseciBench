"""Order detail page: view line items, payments, and grand total."""

import from "@jac/runtime" { Link, useParams, useNavigate }
sv import from ..services.orders { get_order, cancel_order }


def status_color(status: str) -> str {
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
    
    params = useParams();
    nav = useNavigate();
    order_id: str = str(params["id"]) if params["id"] else "";

    async def refresh() -> None {
        if order_id {
            result = await get_order(order_id);
            order = result;
            loading = False;
        }
    }

    async can with entry {
        await refresh();
    }

    async def do_cancel() -> None {
        if order_id {
            await cancel_order(order_id);
            await refresh();
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
    total = order["total"] if order and "total" in order else 0.0;
    order_status = order["status"] if order else "";

    return <div className="max-w-4xl mx-auto px-6 py-8">
        <div className="mb-6">
            <Link to="/orders" className="text-blue-600 hover:underline text-sm">← Back to orders</Link>
        </div>

        <div className="bg-white border border-gray-200 rounded-xl p-6 mb-6">
            <div className="flex items-start justify-between mb-4">
                <div>
                    <h1 className="text-2xl font-bold text-gray-900 mb-2">Order {order["id"]}</h1>
                    <div className="text-sm text-gray-500">{order["created_at"]}</div>
                </div>
                <span className={"text-sm rounded-full px-3 py-1 " + status_color(order_status)}>
                    {order_status}
                </span>
            </div>

            <div className="border-t border-gray-200 pt-4 mt-4">
                <h2 className="text-sm font-semibold text-gray-700 mb-2">Shipping Address</h2>
                <div className="text-sm text-gray-600">
                    {order["shipping_address1"]}<br />
                    {order["shipping_address2"] if order["shipping_address2"] else None}<br />
                    {f"{order['shipping_city']}, {order['shipping_state']} {order['shipping_zip']}"}
                </div>
            </div>
        </div>

        <div className="bg-white border border-gray-200 rounded-xl p-6 mb-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">Order Items</h2>
            
            {(<div className="text-sm text-gray-500">No items in this order.</div>) if len(items) == 0 else None}

            <div className="space-y-3">
                {[<div key={item["id"]} className="flex justify-between items-center pb-3 border-b border-gray-100 last:border-b-0">
                    <div className="flex-1">
                        <div className="text-sm font-medium text-gray-900">Variant {item["variant_id"]}</div>
                        <div className="text-xs text-gray-500 mt-1">
                            {"Quantity: " + str(item["quantity"]) + " × $" + str(item["price_snapshot"])}
                        </div>
                        {(<span className="text-xs text-red-600 font-medium">Returned</span>) if item["returned"] else None}
                    </div>
                    <div className="text-sm font-semibold text-gray-900">
                        {"$" + str(item["subtotal"])}
                    </div>
                </div> for item in items]}
            </div>

            <div className="border-t border-gray-200 mt-4 pt-4">
                <div className="flex justify-between items-center">
                    <span className="text-base font-bold text-gray-900">Grand Total</span>
                    <span className="text-base font-bold text-gray-900">{"$" + str(total)}</span>
                </div>
            </div>
        </div>

        {(<div className="flex justify-end">
            <button
                onClick={lambda _e: MouseEvent { do_cancel(); }}
                className="px-6 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 font-medium"
            >
                Cancel Order
            </button>
        </div>) if order_status == "pending" else None}
    </div>;
}

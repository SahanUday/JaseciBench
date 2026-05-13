"""Order detail page: view single order with items, payments, and cancel action."""

sv import from ..services.orders { get_order, cancel_order }
import from "@jac/runtime" { Link, useParams, useNavigate }


def:pub OrderDetailPage() -> JsxElement {
    has order: Any = None;
    has loading: bool = True;

    params = useParams();
    order_id = params["id"];

    async def fetch_order() -> None {
        result = await get_order(order_id);
        order = result;
        loading = False;
    }

    async can with entry {
        await fetch_order();
    }

    async def do_cancel() -> None {
        await cancel_order(order_id);
        await fetch_order();
    }

    def handle_cancel(e: MouseEvent) -> None {
        do_cancel();
    }

    if loading {
        return <div className="max-w-4xl mx-auto px-6 py-12 text-gray-500">Loading...</div>;
    }

    if order == None {
        return <div className="max-w-4xl mx-auto px-6 py-12">
            <p className="text-gray-500 mb-4">Order not found.</p>
            <Link to="/orders" className="text-blue-600 hover:underline">← Back to orders</Link>
        </div>;
    }

    return <div className="max-w-4xl mx-auto px-6 py-8">
        <div className="mb-6">
            <Link to="/orders" className="text-blue-600 hover:underline text-sm">← Back to orders</Link>
        </div>

        <h1 className="text-3xl font-bold text-gray-900 mb-2">Order Details</h1>
        <div className="text-sm text-gray-500 mb-6">Order ID: {order["id"]}</div>

        <div className="bg-white border border-gray-200 rounded-xl p-6 mb-6">
            <div className="grid grid-cols-2 gap-4 mb-4">
                <div>
                    <div className="text-xs text-gray-500 mb-1">Status</div>
                    <div className="text-sm font-medium text-gray-900">{order["status"]}</div>
                </div>
                <div>
                    <div className="text-xs text-gray-500 mb-1">Created</div>
                    <div className="text-sm text-gray-900">{order["created_at"]}</div>
                </div>
            </div>

            <div className="border-t border-gray-200 pt-4">
                <div className="text-xs text-gray-500 mb-1">Shipping Address</div>
                <div className="text-sm text-gray-900">
                    {order["shipping_address1"]}
                    {(", " + order["shipping_address2"]) if order["shipping_address2"] else ""}
                </div>
                <div className="text-sm text-gray-900">
                    {order["shipping_city"] + ", " + order["shipping_state"] + " " + order["shipping_zip"]}
                </div>
                {(<div className="text-sm text-gray-900">{order["shipping_country"]}</div>) if order["shipping_country"] else None}
            </div>
        </div>

        <div className="bg-white border border-gray-200 rounded-xl p-6 mb-6">
            <h2 className="text-lg font-bold text-gray-900 mb-4">Order Items</h2>
            <div className="space-y-3">
                {[<div key={item["id"]} className="flex justify-between items-start pb-3 border-b border-gray-100 last:border-0">
                    <div>
                        <div className="text-sm font-medium text-gray-900">Variant: {item["variant_id"]}</div>
                        <div className="text-xs text-gray-500 mt-1">
                            {"Quantity: " + str(item["quantity"]) + " × $" + str(item["price_snapshot"])}
                        </div>
                        {(<div className="text-xs text-red-600 mt-1">Returned</div>) if item["returned"] else None}
                    </div>
                    <div className="text-sm font-bold text-gray-900">
                        {"$" + str(item["subtotal"])}
                    </div>
                </div> for item in order["items"]]}
            </div>
            <div className="mt-4 pt-4 border-t border-gray-200 flex justify-between items-center">
                <div className="text-sm font-bold text-gray-900">Total</div>
                <div className="text-lg font-bold text-gray-900">{"$" + str(order["total"])}</div>
            </div>
        </div>

        <div className="bg-white border border-gray-200 rounded-xl p-6 mb-6">
            <h2 className="text-lg font-bold text-gray-900 mb-4">Payments</h2>
            <div className="space-y-2">
                {[<div key={p["id"]} className="flex justify-between items-center text-sm">
                    <div>
                        <span className="text-gray-900 font-medium">{p["transaction_type"]}</span>
                        <span className="text-gray-500 ml-2">{p["created_at"]}</span>
                    </div>
                    <div className="font-medium text-gray-900">
                        {("$" + str(p["amount"])) if p["transaction_type"] == "payment" else ("-$" + str(p["amount"]))}
                    </div>
                </div> for p in order["payments"]]}
            </div>
        </div>

        {(<div className="flex justify-end">
            <button
                onClick={handle_cancel}
                className="px-6 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors"
            >
                Cancel Order
            </button>
        </div>) if order["status"] == "pending" else None}
    </div>;
}

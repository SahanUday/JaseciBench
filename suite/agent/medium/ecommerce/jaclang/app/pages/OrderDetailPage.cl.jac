"""Order detail page: view order items, payments, and cancel."""

import from "@jac/runtime" { Link, useParams }
sv import from ..services.orders { get_order, cancel_order }


def:pub OrderDetailPage() -> JsxElement {
    has order: Any = None;
    has loading: bool = True;

    async can with entry {
        order_id = useParams()["id"];
        if order_id {
            result = await get_order(str(order_id));
            order = result;
        }
        loading = False;
    }

    if loading {
        return <div className="max-w-4xl mx-auto px-6 py-12 text-gray-500">Loading...</div>;
    }

    if not order {
        return <div className="max-w-4xl mx-auto px-6 py-12">
            <div className="text-center">
                <p className="text-gray-500 mb-4">Order not found.</p>
                <Link to="/orders">Back to Orders</Link>
            </div>
        </div>;
    }

    return <div className="max-w-4xl mx-auto px-6 py-8">
        <div className="mb-6">
            <Link to="/orders">Back to Orders</Link>
        </div>
        <h1 className="text-2xl font-bold text-gray-900 mb-6">Order {order["id"]}</h1>
        <div className="bg-white rounded-xl border border-gray-200 p-6">
            <p>Status: {order["status"]}</p>
            <p>Address: {order["shipping_address1"]}</p>
        </div>
    </div>;
}

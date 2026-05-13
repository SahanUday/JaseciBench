"""Order detail page: view one order, items, payments, cancel."""

import from "@jac/runtime" { Link, useParams }

sv import from ..services.orders { get_order, cancel_order }


def money(v: Any) -> str {
    return str(int(float(str(v)) * 100) / 100.0);
}


def:pub OrderDetailPage() -> JsxElement {
    has order: Any = None;
    has loading: bool = True;

    params = useParams();
    oid = str(params["id"]);

    async def refresh() -> None {
        result = await get_order(oid);
        order = result;
        loading = False;
    }

    async can with entry {
        await refresh();
    }

    async def do_cancel() -> None {
        await cancel_order(oid);
        await refresh();
    }

    if loading {
        return <div className="max-w-4xl mx-auto px-6 py-12 text-gray-500">Loading...</div>;
    }

    if order is None {
        return <div className="max-w-4xl mx-auto px-6 py-8">
            <div className="mb-6">
                <Link props={{
                    "to": "/orders",
                    "className": "inline-flex items-center gap-2 text-sm text-gray-600 hover:text-gray-900"
                }}>
                    <span>←</span>
                    <span>Back to orders</span>
                </Link>
            </div>
            <div className="p-6 bg-white border border-gray-200 rounded-xl">
                <div className="text-lg font-semibold text-gray-900">Order not found</div>
                <div className="text-sm text-gray-500 mt-1">{oid}</div>
            </div>
        </div>;
    }

    items: list = [];
    payments: list = [];
    if order is not None {
        if "items" in order and order["items"] is not None {
            items = list(order["items"]);
        }
        if "payments" in order and order["payments"] is not None {
            payments = list(order["payments"]);
        }
    }

    total = 0.0;
    for it in items {
        total = total + float(str(it["subtotal"]));
    }
    total = int(total * 100) / 100.0;

    return <div className="max-w-4xl mx-auto px-6 py-8">
        <div className="mb-6">
            <Link props={{
                "to": "/orders",
                "className": "inline-flex items-center gap-2 text-sm text-gray-600 hover:text-gray-900"
            }}>
                <span>←</span>
                <span>Back to orders</span>
            </Link>
        </div>

        <div className="flex items-start justify-between gap-4 mb-6">
            <div className="min-w-0">
                <h1 className="text-2xl font-bold text-gray-900">Order {order["id"]}</h1>
                <div className="text-sm text-gray-600 mt-1">Status: {order["status"]}</div>
                <div className="text-sm text-gray-600 mt-1">
                    {str(order["shipping_address1"]) + ", " + str(order["shipping_city"]) + ", " + str(order["shipping_state"]) + " " + str(order["shipping_zip"])}
                </div>
            </div>

            {(<button
                onClick={lambda _e: MouseEvent { do_cancel(); }}
                className="rounded-lg bg-red-600 px-4 py-2 text-sm font-semibold text-white hover:bg-red-700"
            >Cancel</button>) if order["status"] == "pending" else None}
        </div>

        <div className="grid grid-cols-1 gap-6">
            <div className="bg-white border border-gray-200 rounded-xl">
                <div className="px-5 py-4 border-b border-gray-100">
                    <div className="text-sm font-semibold text-gray-900">Items</div>
                </div>
                <div className="p-5">
                    {(<div className="text-sm text-gray-500">No items.</div>) if len(items) == 0 else None}
                    <div className="space-y-3">
                        {[<div key={it["id"]} className="flex items-start justify-between gap-4">
                            <div className="min-w-0">
                                <div className="text-sm font-semibold text-gray-900">Item {it["id"]}</div>
                                <div className="text-xs text-gray-500 mt-0.5">Variant: {it["variant_id"]}</div>
                                <div className="text-xs text-gray-500 mt-0.5">Qty: {it["quantity"]}</div>
                                <div className="text-xs text-gray-500 mt-0.5">Price: ${money(it["price_snapshot"])}</div>
                            </div>
                            <div className="text-sm font-semibold text-gray-900">${money(it["subtotal"])}</div>
                        </div> for it in items]}
                    </div>

                    <div className="mt-6 pt-4 border-t border-gray-100 flex items-center justify-between">
                        <div className="text-sm font-semibold text-gray-900">Grand total</div>
                        <div className="text-sm font-bold text-gray-900">${money(total)}</div>
                    </div>
                </div>
            </div>

            <div className="bg-white border border-gray-200 rounded-xl">
                <div className="px-5 py-4 border-b border-gray-100">
                    <div className="text-sm font-semibold text-gray-900">Payments</div>
                </div>
                <div className="p-5">
                    {(<div className="text-sm text-gray-500">No payments.</div>) if len(payments) == 0 else None}
                    <div className="space-y-3">
                        {[<div key={p["id"]} className="flex items-start justify-between gap-4">
                            <div className="min-w-0">
                                <div className="text-sm font-semibold text-gray-900">{p["transaction_type"]}</div>
                                <div className="text-xs text-gray-500 mt-0.5">{p["id"]}</div>
                                <div className="text-xs text-gray-500 mt-0.5">Method: {p["payment_method_id"]}</div>
                                <div className="text-xs text-gray-500 mt-0.5">{p["created_at"]}</div>
                            </div>
                            <div className="text-sm font-semibold text-gray-900">${money(p["amount"])}</div>
                        </div> for p in payments]}
                    </div>
                </div>
            </div>
        </div>
    </div>;
}

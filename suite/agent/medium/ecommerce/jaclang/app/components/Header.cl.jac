"""App header: branding + nav links."""

import from "@jac/runtime" { Link }
import from "lucide-react" { ShoppingCart, Package, Search, Home }
sv import from ..services.cart { get_cart }


def:pub Header() -> JsxElement {
    has cart_count: int = 0;

    async can with entry {
        result = await get_cart("user_001");
        if result {
            cart_count = result["count"];
        }
    }

    return <header className="sticky top-0 z-50 border-b border-gray-200 bg-white/90 backdrop-blur">
        <div className="max-w-6xl mx-auto px-6 h-14 flex items-center justify-between">
            <Link to="/" className="flex items-center gap-2 text-gray-900 font-bold tracking-tight">
                <Package size={18} className="text-indigo-600" />
                <span>Jac Mart</span>
            </Link>
            <nav className="flex items-center gap-1">
                <Link to="/" className="px-3 py-1.5 rounded-md text-sm text-gray-600 hover:text-gray-900 hover:bg-gray-100 flex items-center gap-1.5">
                    <Home size={14} />
                    Catalog
                </Link>
                <Link to="/search" className="px-3 py-1.5 rounded-md text-sm text-gray-600 hover:text-gray-900 hover:bg-gray-100 flex items-center gap-1.5">
                    <Search size={14} />
                    Search
                </Link>
                <Link to="/cart" className="px-3 py-1.5 rounded-md text-sm text-gray-600 hover:text-gray-900 hover:bg-gray-100 flex items-center gap-1.5">
                    <ShoppingCart size={14} />
                    Cart
                    {cart_count > 0 and <span className="ml-1 px-1.5 py-0.5 text-xs font-medium text-white bg-indigo-600 rounded-full">{str(cart_count)}</span>}
                </Link>
                <Link to="/orders" className="px-3 py-1.5 rounded-md text-sm text-gray-600 hover:text-gray-900 hover:bg-gray-100">
                    Orders
                </Link>
            </nav>
        </div>
    </header>;
}

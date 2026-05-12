"""Top-level client shell: Router + Routes."""

import from "@jac/runtime" { Router, Routes, Route, Navigate }
import from .components.Header { Header }
import from .pages.CatalogPage { CatalogPage }
import from .pages.ProductPage { ProductPage }
import from .pages.CartPage { CartPage }
import from .pages.OrdersPage { OrdersPage }
import from .pages.OrderDetailPage { OrderDetailPage }
import from .pages.SearchPage { SearchPage }


def:pub Shell() -> JsxElement {
    return <Router>
        <div className="min-h-screen bg-gray-50">
            <Header />
            <Routes>
                <Route path="/" element={<CatalogPage />} />
                <Route path="/products/:id" element={<ProductPage />} />
                <Route path="/cart" element={<CartPage />} />
                <Route path="/orders" element={<OrdersPage />} />
                <Route path="/orders/:id" element={<OrderDetailPage />} />
                <Route path="/search" element={<SearchPage />} />
                <Route path="*" element={<Navigate to="/" replace={True} />} />
            </Routes>
        </div>
    </Router>;
}

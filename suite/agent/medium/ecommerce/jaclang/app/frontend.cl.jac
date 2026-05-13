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
                <Route path="/" component={CatalogPage} />
                <Route path="/products/:id" component={ProductPage} />
                <Route path="/cart" component={CartPage} />
                <Route path="/orders" component={OrdersPage} />
                <Route path="/orders/:id" component={OrderDetailPage} />
                <Route path="/search" component={SearchPage} />
                <Route path="*" component={lambda -> JsxElement { return <Navigate to="/" replace={True} />; }} />
            </Routes>
        </div>
    </Router>;
}

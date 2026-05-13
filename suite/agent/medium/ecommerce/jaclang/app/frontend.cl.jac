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
    return <div className="min-h-screen bg-gray-50 p-8">
        <h1 className="text-2xl font-bold">Test Shell</h1>
        <p>If you see this, the basic shell works.</p>
    </div>;
}

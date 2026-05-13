"""Product card: used on catalog and search."""

import from "@jac/runtime" { Link }


def:pub ProductCard(product: Any) -> JsxElement {
    return <Link
        to={"/products/" + product["id"]}
        className="group block bg-white border border-gray-200 rounded-xl p-4 hover:border-indigo-300 hover:shadow-md transition-all"
    >
        <div className="aspect-[4/3] bg-gradient-to-br from-gray-100 to-gray-50 rounded-lg mb-3 flex items-center justify-center text-gray-300 text-2xl font-light">
            {product["name"][0:1]}
        </div>
        <h3 className="text-sm font-semibold text-gray-900 group-hover:text-indigo-600 transition-colors">
            {product["name"]}
        </h3>
        <p className="text-xs text-gray-500 mt-1 line-clamp-2 leading-relaxed">
            {product["description"]}
        </p>
        <div className="mt-3 flex items-center justify-between">
            <span className="text-sm font-bold text-gray-900">
                {"$" + str(product["min_price"])}
            </span>
            <span className="text-xs text-gray-400">
                {str(len(product["variants"])) + " variants"}
            </span>
        </div>
        {<div className="mt-2 pt-2 border-t border-gray-100 text-xs text-gray-600">
            <span className="text-yellow-500">★</span> {str(product["average_rating"])} ({str(product["review_count"])} reviews)
        </div> if product["review_count"] > 0 else ""}
    </Link>;
}

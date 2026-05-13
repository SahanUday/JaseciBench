"""Test average_product_price() function."""

import from services.catalog { average_product_price }

walker test_average_price {
    can on_root with Root entry {
        avg_price = average_product_price();
        print(f"Average product price: ${avg_price}");
    }
}

with entry {
    root spawn test_average_price();
}

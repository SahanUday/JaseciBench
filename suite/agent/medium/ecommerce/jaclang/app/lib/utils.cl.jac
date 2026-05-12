"""Client-side utilities: cn() class merger and price formatter."""

import from "clsx" { clsx }
import from "tailwind-merge" { twMerge }


def:pub cn(classes: list) -> Any {
    return twMerge(clsx(classes));
}


def:pub format_price(price: float) -> str {
    return "$" + str(int(price * 100) / 100.0);
}

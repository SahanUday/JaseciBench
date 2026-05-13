"""Calculator keypad grid with digit, operator, and control buttons."""

def:pub Key(label: str, kind: str, on_press: Any) -> JsxElement {
    backgrounds = {
        "digit": "#ffffff",
        "op": "#3b82f6",
        "equals": "#10b981",
        "clear": "#ef4444"
    };
    foregrounds = {
        "digit": "#1f2937",
        "op": "#ffffff",
        "equals": "#ffffff",
        "clear": "#ffffff"
    };

    return
        <button
            data-testid={"calc-key-" + label}
            onClick={lambda _e: MouseEvent { on_press(); }}
            style={{
                "padding": "1rem",
                "fontSize": "1.125rem",
                "fontWeight": "600",
                "background": backgrounds[kind],
                "color": foregrounds[kind],
                "border": "1px solid #e5e7eb",
                "borderRadius": "0.5rem",
                "cursor": "pointer"
            }}
        >
            {label}
        </button>;
}

def:pub Keypad(
    on_digit: Any,
    on_op: Any,
    on_equals: Any,
    on_clear: Any,
    on_backspace: Any
) -> JsxElement {
    digits = ["7", "8", "9", "4", "5", "6", "1", "2", "3", "0", "."];
    ops = ["/", "*", "-", "+"];

    return
        <div
            style={{
                "display": "grid",
                "gridTemplateColumns": "repeat(4, 1fr)",
                "gap": "0.5rem"
            }}
        >
            {[<Key
                label={d}
                kind="digit"
                on_press={lambda -> None { on_digit(d); }}
            /> for d in digits]}
            <div></div>
            {[<Key
                label={o}
                kind="op"
                on_press={lambda -> None { on_op(o); }}
            /> for o in ops]}
            <button
                data-testid="calc-key-equals"
                onClick={lambda _e: MouseEvent { on_equals(); }}
                style={{
                    "padding": "1rem",
                    "fontSize": "1.125rem",
                    "fontWeight": "600",
                    "background": "#10b981",
                    "color": "#ffffff",
                    "border": "none",
                    "borderRadius": "0.5rem",
                    "cursor": "pointer",
                    "gridColumn": "span 3"
                }}
            >
                =
            </button>
            <button
                data-testid="calc-key-clear"
                onClick={lambda _e: MouseEvent { on_clear(); }}
                style={{
                    "padding": "1rem",
                    "fontSize": "1.125rem",
                    "fontWeight": "600",
                    "background": "#ef4444",
                    "color": "#ffffff",
                    "border": "none",
                    "borderRadius": "0.5rem",
                    "cursor": "pointer"
                }}
            >
                C
            </button>
            <button
                data-testid="calc-key-backspace"
                onClick={lambda _e: MouseEvent { on_backspace(); }}
                style={{
                    "padding": "1rem",
                    "fontSize": "1.125rem",
                    "fontWeight": "600",
                    "background": "#ef4444",
                    "color": "#ffffff",
                    "border": "none",
                    "borderRadius": "0.5rem",
                    "cursor": "pointer"
                }}
            >
                ⌫
            </button>
        </div>;
}

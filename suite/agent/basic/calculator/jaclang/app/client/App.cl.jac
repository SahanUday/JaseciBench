"""Calculator client app with authentication and calculation state machine."""

import from "@jac/runtime" { jacSignup, jacLogin, jacLogout, jacIsLoggedIn }

sv import from server.compute { Compute, ListHistory, ClearHistory, SumHistory }

import from .components.Display { Display }
import from .components.Keypad { Keypad }


def:pub app -> JsxElement {
    has is_logged_in: bool = False,
        username: str = "",
        password: str = "",
        auth_error: str = "",
        auth_busy: bool = False;

    has display: str = "0",
        stored: float = 0.0,
        stored_display: str = "",
        pending_op: str = "",
        awaiting_operand: bool = True,
        last_error: str = "";

    has history: list[dict] = [],
        history_visible: bool = False;

    can with entry {
        is_logged_in = jacIsLoggedIn();
    }

    can with [is_logged_in] entry {
        if is_logged_in {
            refresh_history();
        }
    }

    async def handle_login -> None;
    async def handle_signup -> None;
    def handle_logout -> None;
    def press_digit(d: str) -> None;
    async def press_op(op: str) -> None;
    async def press_equals -> None;
    def press_clear -> None;
    def press_backspace -> None;
    async def refresh_history -> None;
    async def clear_history -> None;
    async def show_history_sum -> None;

    if not is_logged_in {
        return
            <div
                style={{
                    "maxWidth": "20rem",
                    "margin": "4rem auto",
                    "padding": "2rem",
                    "fontFamily": "system-ui, sans-serif",
                    "border": "1px solid #e5e7eb",
                    "borderRadius": "0.75rem"
                }}
            >
                <h2 style={{"marginTop": "0"}}>Calculator - Sign in</h2>
                <input
                    data-testid="auth-username"
                    type="text"
                    value={username}
                    placeholder="Username"
                    onChange={lambda e: ChangeEvent { username = e.target.value; }}
                    style={{
                        "width": "100%",
                        "padding": "0.5rem",
                        "marginBottom": "0.5rem",
                        "border": "1px solid #d1d5db",
                        "borderRadius": "0.375rem",
                        "boxSizing": "border-box"
                    }}
                />
                <input
                    data-testid="auth-password"
                    type="password"
                    value={password}
                    placeholder="Password"
                    onChange={lambda e: ChangeEvent { password = e.target.value; }}
                    style={{
                        "width": "100%",
                        "padding": "0.5rem",
                        "marginBottom": "0.75rem",
                        "border": "1px solid #d1d5db",
                        "borderRadius": "0.375rem",
                        "boxSizing": "border-box"
                    }}
                />
                {(<div style={{"color": "#dc2626", "marginBottom": "0.5rem"}}>{auth_error}</div>)
                    if auth_error else None}
                <div style={{"display": "flex", "gap": "0.5rem"}}>
                    <button
                        data-testid="auth-login"
                        onClick={lambda _e: MouseEvent { handle_login(); }}
                        disabled={auth_busy}
                        style={{
                            "flex": "1",
                            "padding": "0.5rem",
                            "background": "#3b82f6",
                            "color": "#ffffff",
                            "border": "none",
                            "borderRadius": "0.375rem",
                            "cursor": "pointer"
                        }}
                    >
                        Log in
                    </button>
                    <button
                        data-testid="auth-signup"
                        onClick={lambda _e: MouseEvent { handle_signup(); }}
                        disabled={auth_busy}
                        style={{
                            "flex": "1",
                            "padding": "0.5rem",
                            "background": "#ffffff",
                            "color": "#3b82f6",
                            "border": "1px solid #3b82f6",
                            "borderRadius": "0.375rem",
                            "cursor": "pointer"
                        }}
                    >
                        Sign up
                    </button>
                </div>
            </div>;
    }

    preview = "";
    if pending_op {
        if awaiting_operand {
            preview = stored_display + " " + pending_op;
        } else {
            preview = stored_display + " " + pending_op + " " + display;
        }
    }

    return
        <div
            style={{
                "maxWidth": "22rem",
                "margin": "2rem auto",
                "padding": "1.5rem",
                "fontFamily": "system-ui, sans-serif",
                "border": "1px solid #e5e7eb",
                "borderRadius": "0.75rem"
            }}
        >
            <div
                style={{
                    "display": "flex",
                    "justifyContent": "space-between",
                    "alignItems": "center",
                    "marginBottom": "1rem"
                }}
            >
                <h2 style={{"margin": "0"}}>Calculator</h2>
                <button
                    data-testid="auth-logout"
                    onClick={lambda _e: MouseEvent { handle_logout(); }}
                    style={{
                        "padding": "0.25rem 0.75rem",
                        "background": "#f3f4f6",
                        "color": "#1f2937",
                        "border": "1px solid #d1d5db",
                        "borderRadius": "0.375rem",
                        "cursor": "pointer",
                        "fontSize": "0.875rem"
                    }}
                >
                    Log out
                </button>
            </div>
            <Display value={display} preview={preview} error={last_error} />
            <Keypad
                on_digit={press_digit}
                on_op={press_op}
                on_equals={press_equals}
                on_clear={press_clear}
                on_backspace={press_backspace}
            />
            <div style={{"marginTop": "1rem"}}>
                <button
                    data-testid="history-toggle"
                    onClick={lambda _e: MouseEvent {
                        history_visible = not history_visible;
                    }}
                    style={{
                        "padding": "0.375rem 0.75rem",
                        "background": "#f3f4f6",
                        "border": "1px solid #d1d5db",
                        "borderRadius": "0.375rem",
                        "cursor": "pointer",
                        "fontSize": "0.875rem",
                        "marginRight": "0.5rem"
                    }}
                >
                    {("Hide history" if history_visible else "Show history")}
                </button>
                {(<button
                    data-testid="history-clear"
                    onClick={lambda _e: MouseEvent { clear_history(); }}
                    style={{
                        "padding": "0.375rem 0.75rem",
                        "background": "#fee2e2",
                        "color": "#991b1b",
                        "border": "1px solid #fca5a5",
                        "borderRadius": "0.375rem",
                        "cursor": "pointer",
                        "fontSize": "0.875rem",
                        "marginRight": "0.5rem"
                    }}
                >
                    Clear history
                </button>) if history_visible else None}
                {(<button
                    data-testid="history-sum"
                    onClick={lambda _e: MouseEvent { show_history_sum(); }}
                    style={{
                        "padding": "0.375rem 0.75rem",
                        "background": "#dbeafe",
                        "color": "#1e40af",
                        "border": "1px solid #93c5fd",
                        "borderRadius": "0.375rem",
                        "cursor": "pointer",
                        "fontSize": "0.875rem"
                    }}
                >
                    Σ
                </button>) if history_visible else None}
            </div>
            {(<ul
                data-testid="history-list"
                style={{
                    "marginTop": "0.75rem",
                    "padding": "0.5rem 1rem",
                    "background": "#f9fafb",
                    "borderRadius": "0.5rem",
                    "listStyle": "none",
                    "fontFamily": "ui-monospace, SFMono-Regular, monospace",
                    "fontSize": "0.875rem"
                }}
            >
                {[<li
                    key={item["id"]}
                    style={{"padding": "0.25rem 0"}}
                >
                    {str(item["a"])} {item["op"]} {str(item["b"])} = {str(item["result"])}
                </li> for item in history]}
            </ul>) if history_visible else None}
        </div>;
}

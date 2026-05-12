"""Implementation helpers for the Calculator app component."""

impl app.handle_login -> None {
    auth_error = "";
    if not username or not password {
        auth_error = "Enter both username and password.";
        return;
    }
    auth_busy = True;
    success = await jacLogin(username, password);
    auth_busy = False;
    if success {
        is_logged_in = True;
        username = "";
        password = "";
    } else {
        auth_error = "Invalid username or password.";
    }
}

impl app.handle_signup -> None {
    auth_error = "";
    if not username or not password {
        auth_error = "Enter both username and password.";
        return;
    }
    auth_busy = True;
    result = await jacSignup(username, password);
    auth_busy = False;
    if result["success"] {
        is_logged_in = True;
        username = "";
        password = "";
    } else {
        auth_error = str(result["error"]) if result["error"] else "Sign up failed.";
    }
}

impl app.handle_logout -> None {
    jacLogout();
    is_logged_in = False;
    history = [];
    display = "0";
    stored = 0.0;
    stored_display = "";
    pending_op = "";
    awaiting_operand = True;
    last_error = "";
}

impl app.press_digit(d: str) -> None {
    last_error = "";
    if d == "." and "." in display and not awaiting_operand {
        return;
    }
    if awaiting_operand {
        display = ("0." if d == "." else d);
        awaiting_operand = False;
    } else {
        display = ("0" if display == "0" and d != "." else display) + d;
    }
}

impl app.press_op(op: str) -> None {
    if pending_op and not awaiting_operand {
        await press_equals();
    }
    stored = float(display);
    stored_display = display;
    pending_op = op;
    awaiting_operand = True;
}

impl app.press_equals -> None {
    if not pending_op {
        return;
    }
    b = float(display);
    out = root spawn Compute(a=stored, op=pending_op, b=b);
    payload = out.reports[0] if out.reports else None;
    if payload and "error" in payload {
        last_error = payload["error"];
    } elif payload {
        display = str(payload["result"]);
        last_error = "";
        await refresh_history();
    }
    pending_op = "";
    awaiting_operand = True;
}

impl app.press_clear -> None {
    display = "0";
    stored = 0.0;
    stored_display = "";
    pending_op = "";
    awaiting_operand = True;
    last_error = "";
}

impl app.refresh_history -> None {
    out = root spawn ListHistory();
    history = out.reports[0] if out.reports else [];
}

impl app.clear_history -> None {
    root spawn ClearHistory();
    history = [];
}

impl app.press_backspace -> None {
    last_error = "";
    if awaiting_operand {
        return;
    }
    display = display[:-1];
    if not display or display == "-" {
        display = "0";
        awaiting_operand = True;
    }
}

impl app.show_history_sum -> None {
    out = root spawn SumHistory();
    total = out.reports[0] if out.reports else 0.0;
    display = str(total);
}

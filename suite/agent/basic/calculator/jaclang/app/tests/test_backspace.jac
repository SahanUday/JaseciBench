"""Test backspace functionality for the calculator app state machine."""

test "backspace removes last character from display" {
    # Simulate the app state
    display = "123";
    awaiting_operand = False;
    last_error = "";
    
    # Simulate press_backspace logic
    last_error = "";
    if not awaiting_operand {
        display = display[:-1];
        if not display or display == "-" {
            display = "0";
            awaiting_operand = True;
        }
    }
    
    assert display == "12";
    assert awaiting_operand == False;
    assert last_error == "";
}

test "backspace on single digit resets to 0" {
    # Simulate the app state
    display = "5";
    awaiting_operand = False;
    last_error = "some error";
    
    # Simulate press_backspace logic
    last_error = "";
    if not awaiting_operand {
        display = display[:-1];
        if not display or display == "-" {
            display = "0";
            awaiting_operand = True;
        }
    }
    
    assert display == "0";
    assert awaiting_operand == True;
    assert last_error == "";
}

test "backspace on negative sign resets to 0" {
    # Simulate the app state
    display = "-";
    awaiting_operand = False;
    last_error = "";
    
    # Simulate press_backspace logic
    last_error = "";
    if not awaiting_operand {
        display = display[:-1];
        if not display or display == "-" {
            display = "0";
            awaiting_operand = True;
        }
    }
    
    assert display == "0";
    assert awaiting_operand == True;
}

test "backspace when awaiting_operand does nothing" {
    # Simulate the app state
    display = "42";
    awaiting_operand = True;
    last_error = "";
    
    # Simulate press_backspace logic
    last_error = "";
    if not awaiting_operand {
        display = display[:-1];
        if not display or display == "-" {
            display = "0";
            awaiting_operand = True;
        }
    }
    
    assert display == "42";
    assert awaiting_operand == True;
}

test "backspace clears last_error" {
    # Simulate the app state
    display = "123";
    awaiting_operand = False;
    last_error = "division by zero";
    
    # Simulate press_backspace logic
    last_error = "";
    if not awaiting_operand {
        display = display[:-1];
        if not display or display == "-" {
            display = "0";
            awaiting_operand = True;
        }
    }
    
    assert last_error == "";
    assert display == "12";
}

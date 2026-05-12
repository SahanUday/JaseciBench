# Backspace Key Feature Implementation

## Summary
Added a backspace key to the calculator keypad that allows users to delete the last character from the display.

## Changes Made

### 1. Keypad Component (`client/components/Keypad.cl.jac`)
- Added `on_backspace` parameter to the Keypad function signature
- Added a new backspace button with:
  - Label: `⌫`
  - `data-testid="calc-key-backspace"`
  - Red background styling (matching the clear button)
  - Positioned after the clear button in the bottom row

### 2. App Component (`client/App.cl.jac`)
- Added `def press_backspace -> None;` function declaration
- Wired `press_backspace` to the Keypad component via `on_backspace={press_backspace}`

### 3. App Implementation (`client/App.impl.jac`)
- Implemented `press_backspace` with the following behavior:
  - Always clears `last_error`
  - If `awaiting_operand` is true, does nothing (returns early)
  - Otherwise, removes the last character from `display` using string slicing `[:-1]`
  - If the result is empty or just `"-"`, resets `display` to `"0"` and sets `awaiting_operand = true`

## Testing
- All baseline tests continue to pass (`jac test tests/baseline.jac`)
- Created unit tests for backspace logic in `tests/test_backspace.jac`
- Verified with `jac check main.jac` - no errors

## Behavior Examples
1. Display "123" → press backspace → "12"
2. Display "5" → press backspace → "0" (and awaiting_operand = true)
3. Display "-" → press backspace → "0" (and awaiting_operand = true)
4. When awaiting_operand is true → backspace does nothing
5. Any error message is cleared when backspace is pressed

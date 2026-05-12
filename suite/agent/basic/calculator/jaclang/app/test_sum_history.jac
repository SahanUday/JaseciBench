"""Test SumHistory walker."""

import from server.compute { Compute, ClearHistory, SumHistory }

test "sum_history returns 0.0 for empty history" {
    root() spawn ClearHistory();
    out = root() spawn SumHistory();
    assert out.total == 0.0;
    assert out.reports[0] == 0.0;
}

test "sum_history accumulates results correctly" {
    root() spawn ClearHistory();
    root() spawn Compute(a=2.0, op="+", b=3.0);  # result = 5.0
    root() spawn Compute(a=10.0, op="*", b=2.0);  # result = 20.0
    root() spawn Compute(a=8.0, op="-", b=3.0);  # result = 5.0
    out = root() spawn SumHistory();
    assert out.total == 30.0;  # 5.0 + 20.0 + 5.0
    assert out.reports[0] == 30.0;
}

test "sum_history only counts successful calculations" {
    root() spawn ClearHistory();
    root() spawn Compute(a=5.0, op="+", b=5.0);  # result = 10.0
    root() spawn Compute(a=10.0, op="/", b=0.0);  # error - not saved
    root() spawn Compute(a=3.0, op="*", b=4.0);  # result = 12.0
    out = root() spawn SumHistory();
    assert out.total == 22.0;  # 10.0 + 12.0 (error not included)
}

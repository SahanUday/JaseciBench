"""Test for SumHistory walker."""

import from server.compute { Compute, ClearHistory, SumHistory }

test "sum_history returns 0.0 for empty history" {
    root() spawn ClearHistory();
    out = root() spawn SumHistory();
    assert out.total == 0.0;
}

test "sum_history accumulates all calculation results" {
    root() spawn ClearHistory();
    root() spawn Compute(a=2.0, op="+", b=3.0);      # result: 5.0
    root() spawn Compute(a=10.0, op="*", b=10.0);    # result: 100.0
    root() spawn Compute(a=20.0, op="-", b=5.0);     # result: 15.0
    out = root() spawn SumHistory();
    assert out.total == 120.0;                        # 5.0 + 100.0 + 15.0
}

test "sum_history ignores failed calculations" {
    root() spawn ClearHistory();
    root() spawn Compute(a=5.0, op="+", b=5.0);      # result: 10.0
    root() spawn Compute(a=1.0, op="/", b=0.0);      # error: division by zero
    root() spawn Compute(a=3.0, op="*", b=4.0);      # result: 12.0
    out = root() spawn SumHistory();
    assert out.total == 22.0;                         # 10.0 + 12.0
}

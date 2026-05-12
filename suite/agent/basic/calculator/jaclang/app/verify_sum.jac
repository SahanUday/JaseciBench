"""Quick verification that SumHistory works correctly."""

import from server.compute { Compute, ClearHistory, SumHistory }

with entry {
    # Clear any existing history
    root spawn ClearHistory();
    
    # Add some calculations
    root spawn Compute(a=5.0, op="+", b=5.0);      # 10.0
    root spawn Compute(a=3.0, op="*", b=4.0);      # 12.0
    root spawn Compute(a=20.0, op="-", b=2.0);     # 18.0
    
    # Sum the history
    result = root spawn SumHistory();
    print("Total from SumHistory:", result.total);
    print("Expected: 40.0");
    assert result.total == 40.0, f"Expected 40.0, got {result.total}";
    
    # Test empty history
    root spawn ClearHistory();
    result2 = root spawn SumHistory();
    print("Total from empty history:", result2.total);
    print("Expected: 0.0");
    assert result2.total == 0.0, f"Expected 0.0, got {result2.total}";
    
    print("\n✓ All verifications passed!");
}

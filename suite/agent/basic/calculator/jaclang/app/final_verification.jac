"""Final end-to-end verification of SumHistory feature."""

import from server.compute { Compute, ClearHistory, SumHistory, ListHistory }

with entry {
    print("== SumHistory Feature Verification ==\n");
    
    # Test 1: Empty history
    print("Test 1: Empty history");
    root spawn ClearHistory();
    result = root spawn SumHistory();
    assert result.total == 0.0;
    print("✓ Empty history returns 0.0\n");
    
    # Test 2: Single calculation
    print("Test 2: Single calculation");
    root spawn ClearHistory();
    root spawn Compute(a=5.0, op="+", b=3.0);
    result = root spawn SumHistory();
    assert result.total == 8.0;
    print("✓ Single calculation: 5 + 3 = 8, sum = 8.0\n");
    
    # Test 3: Multiple calculations
    print("Test 3: Multiple calculations");
    root spawn ClearHistory();
    root spawn Compute(a=10.0, op="+", b=5.0);     # 15.0
    root spawn Compute(a=3.0, op="*", b=4.0);      # 12.0
    root spawn Compute(a=20.0, op="-", b=8.0);     # 12.0
    root spawn Compute(a=100.0, op="/", b=4.0);    # 25.0
    result = root spawn SumHistory();
    expected = 15.0 + 12.0 + 12.0 + 25.0;
    assert result.total == expected;
    print(f"✓ Multiple calculations sum: {expected}\n");
    
    # Test 4: With errors (should skip failed calculations)
    print("Test 4: Calculations with errors");
    root spawn ClearHistory();
    root spawn Compute(a=10.0, op="+", b=10.0);    # 20.0 - success
    root spawn Compute(a=5.0, op="/", b=0.0);      # error - should not count
    root spawn Compute(a=5.0, op="*", b=3.0);      # 15.0 - success
    result = root spawn SumHistory();
    assert result.total == 35.0;
    print("✓ Errors excluded from sum: 20 + 15 = 35.0\n");
    
    # Test 5: Modulo operation
    print("Test 5: With modulo operation");
    root spawn ClearHistory();
    root spawn Compute(a=10.0, op="%", b=3.0);     # 1.0
    root spawn Compute(a=7.0, op="+", b=3.0);      # 10.0
    result = root spawn SumHistory();
    assert result.total == 11.0;
    print("✓ Modulo included: 1 + 10 = 11.0\n");
    
    # Test 6: Verify report structure
    print("Test 6: Verify walker reports correctly");
    root spawn ClearHistory();
    root spawn Compute(a=5.0, op="+", b=5.0);
    walker_result = root spawn SumHistory();
    # Check that total is accessible as attribute
    assert hasattr(walker_result, 'total');
    # Check that it's also in reports
    assert len(walker_result.reports) > 0;
    assert walker_result.reports[0] == 10.0;
    print("✓ Walker reports total correctly\n");
    
    print("== All Verifications Passed! ==");
    print("\nFeature Summary:");
    print("✓ SumHistory walker implemented");
    print("✓ Accumulates all Calculation.result values");
    print("✓ Returns 0.0 for empty history");
    print("✓ Excludes failed calculations");
    print("✓ Reports total via report statement");
    print("✓ Works with all operators (+, -, *, /, %)");
}

"""Full-stack calculator app entry point."""

to sv:

import from server.compute { Compute, ListHistory, ClearHistory, SumHistory }

to cl:

import from client.App { app as CalculatorApp }

def:pub app -> JsxElement {
    return
        <CalculatorApp />;
}

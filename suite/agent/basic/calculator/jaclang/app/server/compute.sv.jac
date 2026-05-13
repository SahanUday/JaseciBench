"""Server-side compute walkers: Compute, ListHistory, ClearHistory."""

import from .models { Calculation }

glob calc_counter: int = 0;

def _next_id -> str {
    global calc_counter;
    calc_counter += 1;
    return "calc_" + str(calc_counter);
}

def _to_dict(c: Calculation) -> dict {
    return {
        "id": c.id,
        "a": c.a,
        "op": c.op,
        "b": c.b,
        "result": c.result,
    };
}

walker:priv Compute {
    has a: float,
        op: str,
        b: float;
    has result: float = 0.0;
    has error: str = "";
    has saved_id: str = "";

    can run with Root entry {
        if self.op == "+" {
            value = self.a + self.b;
        } elif self.op == "-" {
            value = self.a - self.b;
        } elif self.op == "*" {
            value = self.a * self.b;
        } elif self.op == "/" {
            if self.b == 0.0 {
                self.error = "division by zero";
                report {"error": self.error};
                return;
            }
            value = self.a / self.b;
        } elif self.op == "%" {
            if self.b == 0.0 {
                self.error = "modulo by zero";
                report {"error": self.error};
                return;
            }
            value = self.a % self.b;
        } else {
            self.error = "unknown operator: " + self.op;
            report {"error": self.error};
            return;
        }
        self.result = value;
        new_id = _next_id();
        new_calc = here ++> Calculation(
            id=new_id, a=self.a, op=self.op, b=self.b, result=value
        );
        if new_calc {
            self.saved_id = new_id;
            report _to_dict(new_calc[0]);
        }
    }
}

walker:priv ListHistory {
    has items: list[dict] = [];

    can collect with Root entry {
        visit [-->];
    }

    can gather with Calculation entry {
        self.items.append(_to_dict(here));
    }

    can finish with Root exit {
        report self.items;
    }
}

walker:priv ClearHistory {
    has deleted: int = 0;

    can collect with Root entry {
        visit [-->];
    }

    can drop with Calculation entry {
        self.deleted += 1;
        del here;
    }

    can finish with Root exit {
        report {"deleted": self.deleted};
    }
}

walker:priv SumHistory {
    has total: float = 0.0;

    can collect with Root entry {
        visit [-->];
    }

    can accumulate with Calculation entry {
        self.total += here.result;
    }

    can finish with Root exit {
        report {"total": self.total};
    }
}

# Running an Evaluation

How to run a coding agent against JaseciBench and get a per-task pass/fail score from the hidden vault.

## TL;DR

```bash
# 1. clone the public benchmark (your agent will edit files here)
git clone https://github.com/Thamirawaran/JaseciBench.git
cd JaseciBench

# 2. let your agent edit files in suite/agent/.../<app>/app/
#    pointing it at one of the task suites
#    (each task's spec is in tasks/<id>/issue.md)

# 3. commit + push to a branch on your fork
git checkout -b eval/my-run
git add -A
git commit -m "eval run"
git push origin eval/my-run

# 4. grade it (FULL sha, not the short one)
JASECIBENCH_EVAL_TOKEN=ghp_xxx ./scripts/grade \
    --repo  YourOrg/JaseciBench \
    --sha   $(git rev-parse HEAD)
```

The script dispatches the vault's grading workflow, polls until done, and prints a per-task results table to your terminal.

## Suite paths

| Suite | Path | Tasks |
|---|---|---:|
| Calculator (basic) | `suite/agent/basic/calculator/jaclang` | 3 |
| Ecommerce (medium) | `suite/agent/medium/ecommerce/jaclang` | 25 |
| **Total** | | **28** |

Each suite has:
- `app/` - the codebase the agent edits (compilable Jac fullstack app)
- `app/tests/baseline.jac` - sanity tests that must keep passing
- `tasks/<id>/issue.md` - public task description the agent reads as its prompt

## Required: full SHA (40 chars), not short SHA (7 chars)

GitHub's `actions/checkout` action can't fetch by short SHA. If you pass `--sha 0655bb2` the workflow will fail with `git fetch ... failed`. Always use `git rev-parse HEAD` or paste the full 40-char SHA.

## Required environment variable

`JASECIBENCH_EVAL_TOKEN` is a fine-grained GitHub PAT with:
- `Actions: write` on `Thamirawaran/JaseciBench-vault` (to trigger workflow_dispatch)
- `Actions: read` on `Thamirawaran/JaseciBench-vault` (to poll status + fetch logs)

Ask a maintainer for one. **Do NOT commit it to any repo.**

## Two execution modes

### `scripts/grade --sha <full-sha>` (no PR needed)

Use this for fast iteration: push a branch, grade, repeat. Sets `pr_number=0` so the vault skips posting back to a PR and just prints results to the workflow log (which `scripts/grade` parses and shows in your terminal).

### `gh workflow run grade-pr` (PR-based)

Use this when you have an open PR you want graded. The vault posts the per-task table as a PR comment.

```bash
# from inside this repo
gh workflow run grade-pr -f pr_number=<N>
```

This needs the `JASECIBENCH_VAULT_DISPATCH_TOKEN` repo secret to be set on this repo by a maintainer.

## How the grading works

Every task in the vault has a `scoring.json` declaring stages:

- `type_check` (gate): `jac check main.jac` must pass.
- `baseline` (gate): `jac test tests/baseline.jac` must pass. **All required, but isolated** - one task's failure does not gate others, because each task is graded in its own workspace copy.
- `hidden` (jac_test): hidden tests injected from the vault.
- `source_contains` (source_contains): specific patterns must appear in specific files (used for UI tasks where rendering can't be tested headlessly).

If any required stage fails on a task, the rest short-circuit for that task and it scores 0. Other tasks are unaffected.

## What your agent sees (and doesn't)

**Visible to your agent:**
- The full source under `suite/agent/.../<app>/app/`
- Each task's `issue.md` (description of what to do)
- `tests/baseline.jac` (the regression tests the agent must not break)

**Hidden from your agent:**
- `tests_hidden.jac` per task (lives only in the private vault)
- `scoring.json` (the rubric)
- The canonical `solution/` overlay (the maintainer-written reference fix)

Your agent only learns whether it passed when grading runs.

## Cumulative vs per-task workspace

The base is shared: when your agent works on task N, it inherits the state from tasks 1..N-1. The vault grades whatever state the candidate's `app/` is in. This matches a "complete this suite" workflow rather than per-task isolated PRs.

That means: a regression introduced while solving task 7 will be visible to task 8's tests. Plan accordingly.

## Local debugging (oracle directly)

If you have read access to `JaseciBench-vault`, you can grade locally without the workflow:

```bash
git clone https://github.com/Thamirawaran/JaseciBench-vault.git ~/vault
cd ~/vault
jac run oracle/score.jac -- \
    --task     0001-cart-total \
    --app      medium/ecommerce/jaclang \
    --codebase /path/to/your/JaseciBench/suite/agent/medium/ecommerce/jaclang/app
```

This runs one task. Output is JSON with per-stage `passed` flags.

## Known gotchas

| Gotcha | Workaround |
|---|---|
| **Short SHA in `scripts/grade --sha`** | Always pass full 40-char SHA |
| **Baseline failure tanks task on that workspace only** | Other tasks are independent; check the per-task table |
| **`actions/checkout` needs auth for private fork** | The vault uses `JASECIBENCH_PUBLIC_PR_COMMENT_TOKEN` to read; if your fork is private, ensure that token has access |
| **`OPENAI_API_KEY` / `ANTHROPIC_API_KEY` not set** | The runner reads these from the calling environment; export before invoking |

## Reference

- Public bench: <https://github.com/Thamirawaran/JaseciBench>
- Private vault: <https://github.com/Thamirawaran/JaseciBench-vault>
- `scripts/grade` lives in this repo: [scripts/grade](scripts/grade)
- Vault grading workflow: [`.github/workflows/grade-submission.yml`](https://github.com/Thamirawaran/JaseciBench-vault/blob/main/.github/workflows/grade-submission.yml) (vault, may require access)
